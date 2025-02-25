@tool
extends Resource
class_name ItemData

@export var ItemName : String
enum ITEM_TYPE { GENERIC, CONSUMABLE, TOOL, CURRENCY, ARTIFACT }
@export var type: ITEM_TYPE
@export var ItemEffects : Array[ItemEffect] = [] 
@export var Equipable : bool
@export var UseTime : float = 0
@export var CooldownTime : float = 0.25

@export_category("Visual Settings")
@export var Icon : Texture2D
@export var ItemModelPrefab : PackedScene #replace with type Equipment later 
@export var EquipModel : PackedScene

func use_item(target):
	call_item_effects(target)
	
func call_item_effects(target): 
	for effect in ItemEffects:
		effect.apply_effect(target)
