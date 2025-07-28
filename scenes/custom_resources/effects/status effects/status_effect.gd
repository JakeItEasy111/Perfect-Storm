extends Effect
class_name StatusEffect

@export var status : Status 

func _has_status_handler(target : Node) -> bool:
	var children = target.get_children()
	for child in children:
		if child is StatusHandlerComponent:
			return true
	return false  
 
func execute(target : Node): #add this status to status handler
	if not (_has_status_handler(target)) : return

	target.status_handler_component.add_status(status)
