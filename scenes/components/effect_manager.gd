extends Node
class_name EffectManager

signal effect_list_updated

@export var effect_holder : Node

var effects : Array[Effect]
var trigger_lists : Dictionary[Effect.TRIGGER_TYPE, Array] = {}

func _ready() -> void:
	EventBus.effects_applied.connect(add_effects) #item_data
	EventBus.effects_removed.connect(clear_effects)
	EventBus.event_triggered.connect(trigger_effects) 

func add_effects(target, new_effects : Array[Effect]):
	if target != effect_holder:
		return
	
	for effect in new_effects:
		if effect.type == Effect.TRIGGER_TYPE.INSTANT:
			effect.execute(effect_holder)
		else:
			effects.append(effect)
			trigger_lists[effect.type].append(effect)
	update_effects()

func clear_effects(target, target_effects : Array[Effect]):
	if target != effect_holder:
		return
		
	for effect in target_effects:
		effects.erase(effect)
		var index = 0 
		for trigger_effect in trigger_lists[effect.type]:
			if trigger_effect == effect:
				trigger_lists[effect.type].remove_at(index)
			index += 1
	update_effects()

func update_effects():
	effect_list_updated.emit()

func trigger_effects(context : EventContext):
	if context.target != effect_holder:
		return 
		
	var trigger_type
	for trigger in trigger_lists:
		if context.event_type == Effect.TRIGGER_TYPE.keys()[trigger]: #this SHOULD compare to the string 
			trigger_type = trigger 
	
	for effect in trigger_lists[trigger_type]:
		if effect.conditions_met(context):
			effect.execute(effect_holder)
			print("Effect triggered: " + Effect.TRIGGER_TYPE.keys()[trigger_type])
