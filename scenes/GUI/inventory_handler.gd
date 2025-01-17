extends Control
class_name InventoryHandler
 
@export_flags_3d_physics var CollisionMask : int

@export var ItemSlotsCount : int = 8

@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload("res://scenes/GUI/inventory_slot.tscn")

var InventorySlots : Array[InventorySlot] = []
var PlayerBody : CharacterBody3D

func _ready() -> void:
	PlayerBody = get_node("/root/" + get_tree().current_scene.name + "/SubViewportContainer/SubViewport/Player") 
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		slot.OnItemDropped.connect(ItemDroppedOnSlot.bind())
		InventorySlots.append(slot)

func PickupItem(item : ItemData): #handled by signal from interactionArea
	for slot in InventorySlots:
		if(!slot.SlotFilled):
			slot.FillSlot(item)
			break

func ItemDroppedOnSlot(fromSlotID : int, toSlotID : int): #drop on slot, full or empty
	var toSlotItem = InventorySlots[toSlotID].SlotData
	var fromSlotItem = InventorySlots[fromSlotID].SlotData
	
	InventorySlots[toSlotID].FillSlot(fromSlotItem)
	InventorySlots[fromSlotID].FillSlot(toSlotItem)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"
	
func _drop_data(_at_position: Vector2, data: Variant) -> void: #drop in-world
	var newItem = InventorySlots[data["ID"]].SlotData.ItemModelPrefab.instantiate() as Node3D
	InventorySlots[data["ID"]].FillSlot(null)
	
	PlayerBody.get_parent().add_child(newItem)
	newItem.global_position = GetWorldMousePosition()
	
func GetWorldMousePosition() -> Vector3:
	var mousePos = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera_3d()
	var ray_start = cam.project_ray_origin(mousePos)
	var ray_end = ray_start + cam.project_ray_normal(mousePos) * cam.global_position.distance_to(PlayerBody.global_position) * 2
	var world3d : World3D = PlayerBody.get_world_3d()
	var space_state = world3d.direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, CollisionMask)
	
	var results = space_state.intersect_ray(query) 
	if (results):
		return results["position"] as Vector3 + Vector3(0.0, 0.5, 0.0)
	else:
		return ray_start.lerp(ray_end, 0.5) * Vector3(0.0, 0.5, 0.0)
