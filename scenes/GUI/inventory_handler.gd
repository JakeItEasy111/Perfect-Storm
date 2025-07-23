extends Control
class_name InventoryHandler

@export_flags_3d_physics var CollisionMask : int

@export var ItemSlotsCount : int = 12
@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload("res://scenes/GUI/inventory_slot.tscn")

@onready var selector: Sprite2D = $AspectRatioContainer/Panel/MarginContainer/GridContainer/Selector

var InventorySlots : Array[InventorySlot] = []

func _ready() -> void:
	EventBus.equip_item.connect(SelectItem.bind())
	EventBus.on_item_picked_up.connect(PickupItem.bind())
	EventBus.use_equipped_item.connect(UseItemAtSlot.bind())
	
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		slot.OnItemDropped.connect(ItemDroppedOnSlot.bind())
		InventorySlots.append(slot)

func PickupItem(item : ItemData): #handled by signal from interactionArea
	for slot in InventorySlots:
		if(slot.SlotFilled):
			
			if slot.SlotData.Consumable:
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
	slot.SlotData.use_item(Global.player)
	
	if !InventorySlots[index].SlotData.Consumable: return
	
	if slot.stack > 1:
		slot.decrementQuantity()
		return
	
	slot.deplete_stack()
	selector.hide() 

func ItemDroppedOnSlot(fromSlotID : int, toSlotID : int): #drop on slot, full or empty
	var toSlotItem = InventorySlots[toSlotID].SlotData
	var fromSlotItem = InventorySlots[fromSlotID].SlotData
	
	var toSlotStack = InventorySlots[toSlotID].stack
	var fromSlotStack = InventorySlots[fromSlotID].stack
	
	InventorySlots[toSlotID].FillSlot(fromSlotItem, fromSlotStack)
	InventorySlots[fromSlotID].FillSlot(toSlotItem, toSlotStack)
	selector.hide()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"

func SelectItem(slot):
	var selected_index = slot.InventorySlotID
	selector.global_position = InventorySlots[selected_index].global_position + Vector2(60, 60)
	selector.show()
	
