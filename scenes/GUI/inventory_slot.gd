extends Control
class_name InventorySlot

signal OnItemDropped(fromSlotID, toSlotID)
signal SlotSelected(index)

@export var IconSlot : TextureRect
@onready var quantity_label: Label = $QuantityLabel

var InventorySlotID : int = -1
var SlotFilled : bool = false
var SlotData : ItemData
var stack : int = 1

func FillSlot(data: ItemData, stack_size : int):
	SlotData = data
	if(SlotData != null):
		SlotFilled = true
		IconSlot.texture = data.Icon
		
		#match SlotData.type:
			#SlotData.ITEM_TYPE.CONSUMABLE:
				#SlotData.connect("stack_depleted", on_stack_depleted)
				#SlotData.connect("stack_updated", on_stack_updated)
				#on_stack_updated()
	else:
		SlotFilled  = false
		IconSlot.texture = null 
	stack = stack_size
	update_stack()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if (SlotFilled):
		var preview : TextureRect = TextureRect.new()
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.size = IconSlot.size
		preview.pivot_offset = IconSlot.size / 2.0 
		preview.modulate.a = 0.5
		preview.texture = IconSlot.texture
		set_drag_preview(preview)
		return {"Type": "Item", "ID": InventorySlotID} #dictionary of item info
	else:
		return false
		
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	OnItemDropped.emit(data["ID"], InventorySlotID)

func deplete_stack():
	FillSlot(null, 1)

func addQuantity(addedQuant : int):
	if stack + addedQuant <= SlotData.max_quantity:
		stack += addedQuant
		update_stack()
#
func decrementQuantity():
	stack -= 1
	if stack <= 0:
		deplete_stack()
		stack = 1
	else:
		update_stack()

func update_stack():
	quantity_label.visible = stack > 1
	quantity_label.text = str(stack)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		if SlotFilled and SlotData:
			SlotSelected.emit(InventorySlotID)
