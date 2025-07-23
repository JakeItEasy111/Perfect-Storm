extends Resource
class_name Stat

signal stat_adjusted(_stat : Stat)

@export var base_value : float = 0 :
	set(new_base_value):
		base_value = new_base_value
		calculate_stat_modifiers()

var stat_modifiers : Array[StatModifier] = []
var adjusted_value : float 

func calculate_stat_modifiers() -> void:
	adjusted_value = base_value

	if stat_modifiers.is_empty(): return 
	
	for mod in stat_modifiers:
		match mod.type:
			StatModifier.StatModifierType.ADD:
				adjusted_value += mod.value
			StatModifier.StatModifierType.SUB:
				adjusted_value -= mod.value
			StatModifier.StatModifierType.MULT:
				adjusted_value *= mod.value
			StatModifier.StatModifierType.DIVIDE:
				adjusted_value /= mod.value
			StatModifier.StatModifierType.PERCENT_ADD:
				adjusted_value += (adjusted_value * mod.value) / 100
			StatModifier.StatModifierType.PERCENT_MULT:
				adjusted_value *= (adjusted_value * mod.value) / 100
			StatModifier.StatModifierType.PERCENT_DIVIDE:
				adjusted_value /= (adjusted_value * mod.value) / 100 
	stat_adjusted.emit(self)

func add_stat_modifier(new_stat_modifier : StatModifier) -> void:
	stat_modifiers.append(new_stat_modifier)
	calculate_stat_modifiers()

func remove_stat_modifier(modifier_to_remove : StatModifier) -> void:
	stat_modifiers.erase(modifier_to_remove)
	calculate_stat_modifiers()
