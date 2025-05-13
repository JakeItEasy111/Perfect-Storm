class_name DamageEffect
extends Effect

@export var flat := true 
@export var amount := 0

func execute(target: Node) -> void:
	if target is Player:
		if flat:
			target.health_component.damage(amount)
		else:
			target.health_component.damage_percent(amount)
