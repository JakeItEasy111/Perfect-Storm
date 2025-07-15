class_name StatusHandlerComponent
extends Node

const STATUS_APPLY_INTERVAL := 0.25

@export var status_owner : Node
var status_effects : Array[StatusEffect]

func apply_statuses():
	
	var tween := create_tween()
	for status in status_effects:
		tween.tween_callback(status.apply_status.bind(status_owner))
		tween.tween_interval(STATUS_APPLY_INTERVAL)
		_on_status_applied(status)
	
func add_status(status : StatusEffect) -> void:
	var stackable := status.stack_type != StatusEffect.StackType.NONE
	
	#To add if the effect is new
	if not _has_status(status.id):
		status_effects.append(status)
		status.status_applied.connect(_on_status_applied)
		status.initialize_status(status_owner)
		return
	
	# If it's unique and we already have it 
	if not status.can_expire and not stackable:
		return 
	
	if status.can_expire and status.stack_type == StatusEffect.StackType.DURATION:
		_get_status(status.id).duration += status.duration
		for timer in get_children():
			if timer.name == status.id:
				timer.time_left += status.duration
		return
	
	if status.stack_type == StatusEffect.StackType.INTENSITY:
		_get_status(status.id).stacks += status.stacks
		return
		
func _has_status(id : String):
	for effect in status_effects:
		if effect.id == id:
			return true
		
		return false
	
func _get_status(id : String):
	for effect in status_effects:
		if effect.id == id:
			return effect
		
		return null 
	
func _on_status_applied(status: StatusEffect) -> void:
	EventBus.status_applied.emit(status)
	run_status_duration(status)

func run_status_duration(status : StatusEffect) -> void:
	if status.can_expire:
		var timer := Timer.new()
		timer.name = status.id
		add_child(timer)
		timer.wait_time = status.duration
		timer.one_shot = true
		timer.connect("timeout", status_expired(status))
		timer.start()
		
		if status is TickStatus:
			run_tick_status(status) 
			
		await timer.timeout
		timer.queue_free()
	
func status_expired(expired_status : StatusEffect):
	expired_status.on_status_removed(status_owner)
	status_effects.erase(expired_status)

func run_tick_status(status : TickStatus):
	var timer := Timer.new()
	timer.name = status.id + "Interval"
	timer.wait_time = status.tick_interval
	
	await timer.timeout
	status.base_effect.execute(status_owner)
	run_tick_status(status)
