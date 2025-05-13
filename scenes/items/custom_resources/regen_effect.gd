class_name RegenEffect
extends HealthEffect

@export var num_ticks : int
@export var tick_rate_seconds : float 

func execute(target: Node) -> void:
	if target is Player:
		target.health_component.regen(amount, num_ticks, tick_rate_seconds, flat)
