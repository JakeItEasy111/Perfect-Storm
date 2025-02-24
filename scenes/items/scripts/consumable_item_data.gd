extends ItemData
class_name ConsumableItemData

@export_category("Consumables")
@export var use_time_sec : float
@export var cooldown_sec : float 

@export_group("Stacks") 
@export_range(0, 99) var max_quantity : int = 1 

func use_item(target):
	pass
