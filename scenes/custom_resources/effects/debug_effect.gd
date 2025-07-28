extends Effect
class_name DebugMessageEffect

@export var debug_message : String 

func execute(_target: Node) -> void:
	print("Debug message: " + debug_message)
