class_name EquipmentComponent
extends Marker3D

var current_item : ItemData #holds item data
var current_item_slot : int = -1 #holds slot ID

func _ready() -> void:
	EventBus.connect("equip_item", load_item.bind())
	EventBus.connect("action_timer_complete", use_equipped_item)

func _unhandled_input(event: InputEvent) -> void:
	if item_equipped():
		if event.is_action_pressed("use"):
			EventBus.action_timer_begin.emit(current_item.UseTime) #replace with item use time
		if event.is_action_released("use"):
			EventBus.action_timer_end.emit(current_item.CooldownTime)
	
func load_item(item_slot : InventorySlot):
	if(item_slot != null):
		if current_item == item_slot.SlotData: return 
		
		if current_item != null:
			load_item(null)
			load_item(item_slot)
		else:
			current_item_slot = item_slot.InventorySlotID
			current_item = item_slot.SlotData
			
			var equipped_item_prefab = current_item.EquipModel
			var instance = equipped_item_prefab.instantiate()
			add_child(instance)
			
	else:
		current_item_slot = -1
		current_item = null
		get_children()[0].queue_free()


func item_equipped():
	return get_child_count() > 0 and current_item != null

func use_equipped_item():
	if item_equipped():
		EventBus.equipped_item_used.emit(current_item_slot)
		load_item(null)
