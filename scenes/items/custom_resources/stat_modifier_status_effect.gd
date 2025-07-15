extends StatusEffect
class_name StatModifierStatus

@export var stat_modifier : StatModifier

func apply_status(target: Node) -> void: #trigger actual status effect 
	target.stat_modifiers.append(stat_modifier)

func on_status_removed(target: Node) -> void:
	super.on_status_removed(target) 
	target.stat_modifiers.erase(stat_modifier)
 
