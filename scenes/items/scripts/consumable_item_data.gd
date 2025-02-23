extends ItemData
class_name ConsumableItemData

#signal stack_depleted()
#signal stack_updated() 

@export_category("Consumables")
@export var use_time_sec : float
@export var cooldown_sec : float 

@export_group("Stacks") 
@export_range(0, 99) var max_quantity : int = 1 
#@export var quantity : int = 1 #PROBLEM: THIS IS BAD! quantity should be handled by the inventory, this results in many things that are bad 
#
#func addQuantity(addedQuant : int):
	#if quantity + addedQuant <= max_quantity:
		#quantity += addedQuant
		#stack_updated.emit()
#
#func decrementQuantity():
	#quantity -= 1
	#if quantity <= 0:
		#stack_depleted.emit()
		#quantity = 1
	#else:
		#stack_updated.emit()

#func use_item(target):
	#decrementQuantity()
