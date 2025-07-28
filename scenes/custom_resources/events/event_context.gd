extends Node
class_name EventContext

var event_type : String 
var source : Node
var data : Node
var target : Node

func initialize(_event_type : String = "", _source : Node = null, _data : Node = null, _target : Node = null) -> void:
	event_type = _event_type
	source = _source
	data = _data
	target = _target 
