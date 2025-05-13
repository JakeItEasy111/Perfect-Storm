class_name StatusHandler
extends Node

@export var status_owner : Node
var status_effects : Array[StatusEffect]

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
		return
	
	if status.stack_type == StatusEffect.StackType.INTENSITY:
		_get_status(status.id).stacks += status.stacks
		return
		
func _has_status(id : String):
	pass
	
func _get_status(id : String):
	pass
	
func _on_status_applied():
	pass
