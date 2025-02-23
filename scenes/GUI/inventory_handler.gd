extends Control
class_name InventoryHandler

signal use_item()

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
		slot.SlotSelected.connect(UseItemAtSlot.bind())
		InventorySlots.append(slot)

func PickupItem(item : ItemData): #handled by signal from interactionArea
	for slot in InventorySlots:
		if(slot.SlotFilled):
			match slot.SlotData.type:
				slot.SlotData.ITEM_TYPE.CONSUMABLE:
					if slot.SlotData == item:
						if slot.stack >= slot.SlotData.max_quantity: 
							continue
						slot.addQuantity(1)
						return
		else:
			slot.FillSlot(item, 1)
			return

func UseItemAtSlot(index : int) -> void:
	if index < 0 || index >= InventorySlots.size() || !InventorySlots[index].SlotData: return
	
	var slot = InventorySlots[index]
	use_item.emit(slot.SlotData)
	slot.SlotData.use_item(Global.player)
	
	if slot.stack > 1:
		slot.decrementQuantity()
		return
	
	slot.deplete_stack()

func ItemDroppedOnSlot(fromSlotID : int, toSlotID : int): #drop on slot, full or empty
	var toSlotItem = InventorySlots[toSlotID].SlotData
	var fromSlotItem = InventorySlots[fromSlotID].SlotData
	
	var toSlotStack = InventorySlots[toSlotID].stack
	var fromSlotStack = InventorySlots[fromSlotID].stack
	
	InventorySlots[toSlotID].FillSlot(fromSlotItem, fromSlotStack)
	InventorySlots[fromSlotID].FillSlot(toSlotItem, toSlotStack)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"
