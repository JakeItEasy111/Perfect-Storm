extends Node
class_name InventoryHandler

@export var ItemSlotsCount : int = 8

@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload("res://scenes/GUI/inventory_slot.tscn")

var InventorySlots : Array[InventorySlot] = []

func _ready() -> void:
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		InventorySlots.append(slot)

func PickupItem(item : ItemData): #handled by signal from interactionArea
	for slot in InventorySlots:
		if(!slot.SlotFilled):
			slot.FillSlot(item)
			break
