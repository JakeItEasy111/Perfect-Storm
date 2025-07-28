class_name Effect
extends Resource

signal effect_triggered(source : Effect)

enum TRIGGER_TYPE {
	INSTANT,
	ON_EQUIP,
	ON_DAMAGE,
	ON_HIT,
	ON_HEAL,
	ON_ITEM_USED,
	ON_LEAVING_DOOR,
	AT_LOW_STAMINA,
	AT_LOW_HEALTH,
	ON_DEATH,
	ON_STAMINA_DRAINED,
}

@export var type : TRIGGER_TYPE
@export var conditions : Array[Condition]

func execute(_target: Node) -> void:
	pass

func conditions_met(context : EventContext) -> bool:
	for condition in conditions:
		if not condition.check(context):
			return false
	return true 
