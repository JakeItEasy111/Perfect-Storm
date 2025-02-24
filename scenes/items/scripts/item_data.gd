@tool
extends Resource
class_name ItemData

signal item_equipped(ItemData)

@export var ItemName : String
enum ITEM_TYPE { GENERIC, CONSUMABLE, TOOL, CURRENCY, ARTIFACT }
@export var type: ITEM_TYPE
@export var ItemEffects : Array[ItemEffect] = [] 
@export var Equipable : bool
@export var EquipItem : PackedScene

@export_category("Visual Settings")
@export var Icon : Texture2D
@export var ItemModelPrefab : PackedScene #replace with type Equipment later 

func use_item(target):
	call_item_effects(target)
	
func call_item_effects(target): 
	for effect in ItemEffects:
		effect.apply_effect(target)
