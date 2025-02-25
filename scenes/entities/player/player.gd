extends CharacterBody3D
class_name Player

# signals 
signal pda_use(is_open) #sent to PDA

# constants
const WALK_SPEED = 2.5
const SPRINT_SPEED = 4.5
const CROUCH_SPEED = 1.25
const PDA_SPEED = 1.75
const CROUCH_TRANSLATE = 0.25
const JUMP_VELOCITY = 3.0
const BOB_FREQ = 3.0
const BOB_AMP = 0.07
const MAX_STEP_HEIGHT = 0.5

var look_sensitivity = 0.003 
var current_speed = 2.5
var direction = Vector3.ZERO
var original_capsule_height = 2.0
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

#sprint bar variables
var sprint_drain_amount = 25
var sprint_regen_amount = 15
var sprint_time_on_screen = 2 #time the slider stays on screen after letting go of shift
var sprint_fade_speed = 2 #how fast the slider fades off once the time on screen has elapsed
var sprint_bar_timer  = 0
var sprint_bar : TextureProgressBar

# fov variables
var fov = 60
var fov_change = 1.25 
var t_bob = 0.0 

# states
var can_jump = true
var can_sprint = true
var can_crouch = true 
var using_pda = false

@onready var head = $Head
@onready var camera = %Camera3D
@onready var collision = $PlayerCollisionShape
@onready var col_above_detect_ray = $ColAboveDetectRay
@onready var fps_arms = %Arms
@onready var stairs_below_raycast_3d: RayCast3D = $StairsBelowRaycast3D
@onready var stairs_ahead_raycast_3d: RayCast3D = $StairsAheadRaycast3D

@export var health_component : HealthComponent
@export var equipment_component : EquipmentComponent

func _ready():
	Global.player = self 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_speed = WALK_SPEED
	sprint_bar = get_node("/root/" + get_tree().current_scene.name + "/PlayerUI/SprintBar")

func _unhandled_input(event: InputEvent) -> void:
	if(!using_pda):
		
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * look_sensitivity) 
			camera.rotate_x(-event.relative.y * look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
		if event.is_action_pressed("inventory") && !fps_arms.anim_player.is_playing():
			pda_use.emit(false) 
			using_pda = true 
			can_sprint = false 
			
			if(current_speed == SPRINT_SPEED):
				current_speed = WALK_SPEED
				can_crouch = true 
		
	else:	
		if event.is_action_pressed("inventory") && !fps_arms.anim_player.is_playing():
			pda_use.emit(true)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			using_pda = false
			can_sprint = true

func _physics_process(delta: float) -> void:
		#jumping
		if(can_jump && (is_on_floor() or _snapped_to_stairs_last_frame) && Input.is_action_just_pressed("jump")):
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
		
		#fov
		var velocity_clamp = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = fov + (fov_change * velocity_clamp)
		camera.fov = lerp(camera.fov, target_fov, delta * 2.0)
		
		#stair handling
		if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
		
		if not _snap_up_stairs_check(delta): 
			# because _snap_up_stairs_check moves the body manually 
			
			# headbob
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin = _headbob(t_bob)
			
			move_and_slide()
			_snap_down_to_stairs_check()
			
func _process(delta: float) -> void:
	# sprint block 
	if Input.is_action_just_pressed("sprint"): 
		if (current_speed == SPRINT_SPEED):
			can_crouch = true 
			current_speed = WALK_SPEED
			sprint_bar_timer = sprint_time_on_screen
		elif (can_sprint && current_speed != CROUCH_SPEED):
			can_crouch = false 
			current_speed = SPRINT_SPEED
		
	if sprint_bar.value <= sprint_bar.min_value:
		can_sprint = false
		sprint_bar.tint_progress = Color.DARK_GRAY
		
	if current_speed == SPRINT_SPEED and Input.get_vector("left", "right", "forward", "backward").length() > 0.1 :  #while sprinting 
		if(!using_pda):
			sprint_bar.visible = true
			sprint_bar.value = sprint_bar.value - sprint_drain_amount * delta
			sprint_bar.tint_progress = Color.WHITE
			
			if !can_sprint:
				can_crouch = true 
				current_speed = WALK_SPEED
			
	else: #not sprinting 
		if sprint_bar_timer > 0:
			sprint_bar_timer = sprint_bar_timer - delta
		if sprint_bar_timer <= 0: 
			sprint_bar.tint_progress.a = sprint_bar.tint_progress.a - sprint_fade_speed * delta
			
			if sprint_bar.tint_progress.a <= 0:
				sprint_bar.visible = false
		
		if sprint_bar.value < sprint_bar.max_value:
			sprint_bar.value = sprint_bar.value + sprint_regen_amount * delta
			sprint_bar_timer = sprint_time_on_screen
			
		if sprint_bar.value == sprint_bar.max_value:
			if sprint_bar.tint_progress == Color.DARK_GRAY: 
				sprint_bar.tint_progress = Color.WHITE
			if !using_pda:
				can_sprint = true
			sprint_bar_timer = 0

	# crouch block 
	if Input.is_action_just_pressed("crouch"):
		if(current_speed == CROUCH_SPEED && !col_above_detect_ray.is_colliding()):
			current_speed = WALK_SPEED 
			can_jump = true
			collision.shape.height = original_capsule_height
			collision.position.y = 0
		elif(can_crouch):
			current_speed = CROUCH_SPEED
			can_jump = false
			collision.shape.height = original_capsule_height - (CROUCH_TRANSLATE * 4)
			collision.position.y = -(collision.shape.height / 2)
			
	if(current_speed == CROUCH_SPEED):
		head.position.y = lerp(head.position.y, -CROUCH_TRANSLATE, delta * 4.0) 
	elif(!col_above_detect_ray.is_colliding()):
		head.position.y = lerp(head.position.y, CROUCH_TRANSLATE, delta * 4.0)  

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP #scale w/ health when implemented
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func is_surface_too_steep(normal : Vector3) -> bool:
		return normal.angle_to(Vector3.UP) > self.floor_max_angle

func _run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func _snap_up_stairs_check(delta) -> bool: 
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	# Run test above the pos we expect to move to with clearance above to ensure ample room for player
	# If it hits a step <= MAX_STEP_HEIGHT, we can move player on top of step 
	var down_check_result = PhysicsTestMotionResult3D.new()
	if(_run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT*2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
			var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
			# Step height <= 0.01 prevents some physics weirdness
			# As the normal character controller can handle step ups of 0.1 
			if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false 
			stairs_ahead_raycast_3d.global_position = down_check_result.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
			stairs_ahead_raycast_3d.force_raycast_update()
			if stairs_ahead_raycast_3d.is_colliding() and not is_surface_too_steep(stairs_ahead_raycast_3d.get_collision_normal()):
				self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
				apply_floor_snap()
				_snapped_to_stairs_last_frame = true
				return true
	return false 

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below : bool = stairs_below_raycast_3d.is_colliding() and not is_surface_too_steep(stairs_below_raycast_3d.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _on_health_component_died() -> void:
	pass # Replace with function body.
