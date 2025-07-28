extends Status
class_name StatModifierStatus

@export var stat_modifier : StatModifier
@export var stat : Stat

func apply_status(target: Node) -> void: #trigger actual status effect 
	super.apply_status(target)
	stat.add_stat_modifier(stat_modifier)

func on_status_removed(target: Node) -> void:
	super.on_status_removed(target) 
	stat.remove_stat_modifier(stat_modifier)
