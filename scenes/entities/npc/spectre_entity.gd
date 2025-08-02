extends CharacterBody3D

const SPEED : float = 2.0 

var chasing : bool = false
var target : Node = null 

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var stall_timer: Timer = $StallTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	chasing = false 
	animation_player.play("speen")

func _physics_process(delta: float) -> void:
	if chasing: 
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * SPEED
		
		if target != null:
			update_target_location(target.global_transform.origin)
			
		velocity = velocity.move_toward(new_velocity, .25)
		move_and_slide()
	
	
func update_target_location(target_location):
	nav_agent.target_position = target_location 

func _on_chase_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body 
		chasing = true 

func _on_chase_range_body_exited(body: Node3D) -> void:
	if body == target:
		target = null
		chasing = false 

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is Player:
		hit_target(body)
		chasing = false
		stall_timer.start()

func hit_target(player_body : Player):
	player_body.health_component.damage(20)
	
	var event = EventContext.new()
	event.event_type = "ON_HIT"
	event.source = self
	event.target = player_body
	
	EventBus.event_triggered.emit(event)

func _on_stall_timer_timeout() -> void:
	chasing = true 
