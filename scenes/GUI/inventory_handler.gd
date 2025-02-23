extends Control
class_name InventoryHandler
 
@export_flags_3d_physics var CollisionMask : int

@export var ItemSlotsCount : int = 8

@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload("res://scenes/GUI/inventory_slot.tscn")

var InventorySlots : Array[InventorySlot] = []

func _ready() -> void:
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		slot.OnItemDropped.connect(ItemDroppedOnSlot.bind())
		InventorySlots.append(slot)

func PickupItem(item : ItemData): #handled by signal from interactionArea
	for slot in InventorySlots:
		if(slot.SlotFilled):
			match slot.SlotData.type:
				slot.SlotData.ITEM_TYPE.CONSUMABLE:
					if slot.SlotData.ItemName == item.ItemName and slot.SlotData.quantity < slot.SlotData.max_quantity: 
						slot.SlotData.addQuantity(1)
						break
		else:
			slot.FillSlot(item)
			break

func ItemDroppedOnSlot(fromSlotID : int, toSlotID : int): #drop on slot, full or empty
	var toSlotItem = InventorySlots[toSlotID].SlotData
	var fromSlotItem = InventorySlots[fromSlotID].SlotData
	
	InventorySlots[toSlotID].FillSlot(fromSlotItem)
	InventorySlots[fromSlotID].FillSlot(toSlotItem)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"
