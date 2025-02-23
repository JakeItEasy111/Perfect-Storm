extends Node

var items : Array[ItemData]

func _ready() -> void:
	var directory = DirAccess.open("res://scenes/items/itemdata")
	directory.list_dir_begin()
	
	var filename = directory.get_next()
	while filename: 
		if not directory.current_is_dir(): #if current is not a directory, then it is a file 
			items.append(load("res://scenes/items/itemdata/%s" % filename)) #loads itemdata from directory to array of items 
		filename = directory.get_next() 

func get_item(item_name):
	for i in items:
		if i.name == item_name:
			return i
	
	return null
