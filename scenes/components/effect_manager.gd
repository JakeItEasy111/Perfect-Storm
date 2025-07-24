extends Node
class_name EffectManager

signal effect_list_updated

var effects : Array[Effect]
@export var trigger_lists : Dictionary[Effect.TRIGGER_TYPE, Array] = {}

func _ready() -> void:
	EventBus.equip_item.connect(trigger_effects.unbind(1).bind(Effect.TRIGGER_TYPE.ON_EQUIP))
	EventBus.item_used.connect(trigger_effects.unbind(1).bind(Effect.TRIGGER_TYPE.ON_ITEM_USED))
	#add as required

func add_effects(new_effects : Array[Effect]):
	for effect in new_effects:
		effects.append(effect)
		trigger_lists[effect.type].append(effect)
	update_effects()

func clear_effects(target_effects : Array[Effect]):
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

func trigger_effects(trigger : Effect.TRIGGER_TYPE):
	for effect in trigger_lists[trigger]:
		effect.execute()
