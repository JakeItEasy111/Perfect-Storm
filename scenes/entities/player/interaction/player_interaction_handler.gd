extends Area3D

var ItemTypes : Array[ItemData] = ItemDatabase.items

var NearbyBodies : Array[InteractibleItem]
var inventory_handler: InventoryHandler
	
func _input(event : InputEvent) -> void:
	if(event.is_action_pressed("interact") && !Global.player.using_pda):
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
			if(ItemTypes[i].WorldPrefab != null and ItemTypes[i].WorldPrefab.resource_path == itemPrefab):
				print("Item ID: " + str(i) + " Item Name: " + ItemTypes[i].ItemName) 
				if ItemTypes[i].ITEM_TYPE.UPGRADE: #add to artifacts 
					Global.player.artifacts.append(ItemTypes[i])
					EventBus.on_upgrade_picked_up.emit(ItemTypes[i])
				elif ItemTypes[i].ITEM_TYPE.PICKUP: #immediately execute 
					ItemTypes[i].apply_effects(Global.player)
					EventBus.on_pickup.emit(ItemTypes[i])
				EventBus.on_item_picked_up.emit(ItemTypes[i]) #add to inventory 
				return 
		
func OnOnjectEnteredArea(body: Node3D):
	if(body is InteractibleItem):
		body.GainFocus()
		NearbyBodies.append(body)

func OnObjectExitedArea(body: Node3D):
	if(body is InteractibleItem and NearbyBodies.has(body)):
		body.LoseFocus()
		NearbyBodies.remove_at(NearbyBodies.find(body))
