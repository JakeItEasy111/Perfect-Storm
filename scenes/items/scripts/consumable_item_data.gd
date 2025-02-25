extends ItemData
class_name ConsumableItemData

@export_category("Consumables")

@export_group("Stacks") 
@export_range(0, 99) var max_quantity : int = 1 

func use_item(target):
	pass
