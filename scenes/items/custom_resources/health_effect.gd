class_name HealthEffect
extends Effect

@export_category("Health Effect")
@export var flat := true 
@export var amount := 0

func execute(target: Node) -> void:
	if target is Player:
		if flat:
			target.health_component.heal_flat(amount)
		else:
			target.health_component.heal_percent(amount)
