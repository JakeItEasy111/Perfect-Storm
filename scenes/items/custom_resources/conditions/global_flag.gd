extends Node

@export var flag : String

func check(target : Node) -> bool: 
	var script = target.get_script()
	var property_list = script.get_script_property_list()
	for property in property_list:
		if property.get("name") == flag:
			property = true if property == false else false
	return false
