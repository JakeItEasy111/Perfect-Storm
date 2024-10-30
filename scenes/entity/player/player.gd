extends CharacterBody3D

signal pda_use

#movement constants
const WALK_SPEED = 2.5
const SPRINT_SPEED = 6.0
const CROUCH_SPEED = 1.25
const JUMP_VELOCITY = 3.5

var current_speed = 3.0 

#headbob constants
const BOB_FREQ = 3.0
const BOB_AMP = 0.065

#fov variables
var fov = 75
var fov_change = 1.25 
var t_bob = 0.0 

var look_sensitivity = 0.003 
var direction = Vector3.ZERO

#states
var can_jump = true
var can_sprint = true
var can_crouch = true 
var can_open_pda = true
var sprinting = false
var crouching = false 
var using_pda = false 
var dead = false 

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var std_col = $standing_col_shape
@onready var crouch_col = $crouching_col_shape
@onready var col_above_detect_ray = $col_above_detect_ray
@onready var fps_arms = $Head/Camera3D/fps_arms

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if(!using_pda):
		
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * look_sensitivity)
			camera.rotate_x(-event.relative.y * look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
		
		if event.is_action_pressed("inventory") && !fps_arms.anim_player.is_playing():
			emit_signal("pda_use")
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			using_pda = true 
			
			if(sprinting):
				current_speed = WALK_SPEED 
				sprinting = false  
				can_crouch = true 
				can_sprint = false 
	else:	
		if event.is_action_pressed("inventory") && !fps_arms.anim_player.is_playing():
			emit_signal("pda_use")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			using_pda = false
			can_sprint = true


func _physics_process(delta: float) -> void:
	
	if(!dead):
		#handling movement states
		if(!using_pda):
			#sprinting
			if Input.is_action_just_pressed("sprint"):
				if(sprinting):
					sprinting = false 
					can_crouch = true 
					current_speed = WALK_SPEED
				elif (can_sprint && !crouching):
					sprinting = true
					can_crouch = false 
					current_speed = SPRINT_SPEED
				
			if sprinting && !can_sprint:
				sprinting = false
				can_crouch = true 
				current_speed = WALK_SPEED
				
			#crouching
			if Input.is_action_just_pressed("crouch"):
				if(crouching && !col_above_detect_ray.is_colliding()):
					crouching = false
					current_speed = WALK_SPEED
					can_jump = true
					std_col.disabled = false
					crouch_col.disabled = true
				elif(can_crouch):
					crouching = true
					current_speed = CROUCH_SPEED
					can_jump = false
					crouch_col.disabled = false
					std_col.disabled = true 
					
			if(crouching):
				head.position.y = lerp(head.position.y, -0.25, delta * 6.0) 
			elif(!col_above_detect_ray.is_colliding()):
				head.position.y = lerp(head.position.y, 0.25, delta * 6.0)  
			
			#jumping
			if(can_jump && is_on_floor() && Input.is_action_just_pressed("jump")):
				velocity.y = JUMP_VELOCITY
			
		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		direction = lerp(direction, (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*10.0) 
		if is_on_floor():
			if direction:
				velocity.x = direction.x * current_speed
				velocity.z = direction.z * current_speed
			else:
				velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 5.0)
				velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 5.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 2.0)
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 2.0)
		
		# gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		#headbob
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
		
		#fov
		var velocity_clamp = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = fov + (fov_change * velocity_clamp)
		camera.fov = lerp(camera.fov, target_fov, delta * 2.0)

		move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP #scale w/ health when implemented
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
