extends Area3D

signal OnItemPickedUp(item)

@export var ItemTypes : Array[ItemData] = []

var NearbyBodies : Array[InteractibleItem]
var inventory_handler : Node

func _ready() -> void:
	inventory_handler = get_node("/root/" + get_tree().current_scene.name + "/SubViewportContainer/SubViewport/Player/Head/Camera3D/Arms/GUI/Viewport/GUI_Interface")
	OnItemPickedUp.connect(inventory_handler.PickupItem)
	
func _input(event : InputEvent) -> void:
	if(event.is_action_pressed("interact") && !get_parent().using_pda):
		PickupNearestItem()
		
func PickupNearestItem():
	var nearestItem : InteractibleItem = null
	var nearestItemDistance : float = INF
	
	for item in NearbyBodies:
		if(item.global_position.distance_to(global_position) < nearestItemDistance):
			nearestItemDistance = item.global_position.distance_to(global_position)
			nearestItem = item
	
	if (nearestItem != null):
		nearestItem.queue_free()
		NearbyBodies.remove_at(NearbyBodies.find(nearestItem))
		var itemPrefab = nearestItem.scene_file_path
		for i in ItemTypes.size(): #if proper item type 
			if(ItemTypes[i].ItemModelPrefab != null and ItemTypes[i].ItemModelPrefab.resource_path == itemPrefab):
				print("Item ID: " + str(i) + " Item Name: " + ItemTypes[i].ItemName) 
				OnItemPickedUp.emit(ItemTypes[i])
				return 
	
	printerr("Item not found.")
		
func OnOnjectEnteredArea(body: Node3D):
	if(body is InteractibleItem):
		body.GainFocus()
		NearbyBodies.append(body)

func OnObjectExitedArea(body: Node3D):
	if(body is InteractibleItem and NearbyBodies.has(body)):
		body.LoseFocus()
		NearbyBodies.remove_at(NearbyBodies.find(body))
