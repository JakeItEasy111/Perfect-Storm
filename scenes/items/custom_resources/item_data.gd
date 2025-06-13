@tool
extends Resource
class_name ItemData

@export var ItemName : String
enum ITEM_TYPE {INVENTORY, UPGRADE, PICKUP}
@export var Type: ITEM_TYPE = ITEM_TYPE.INVENTORY 
@export var ItemEffects : Array[Effect] = [] 

@export_category("Inventory Items")
@export var Equipable : bool 
@export var Consumable : bool
@export var UseTime : float = 0.0
@export_range(0, 99) var max_quantity : int = 1 

@export_category("Visual Settings")
@export var Icon : Texture2D
@export var WorldPrefab : PackedScene 
@export var ViewModel : PackedScene 

func use_item(target):
	apply_effects(target)
	EventBus.item_used.emit(self)
	
func apply_effects(target): 
	for effect in ItemEffects:
		effect.execute(target)
