extends StatusEffect
class_name TickStatus
 
@export_category("Tick Effect Settings")
@export var tick_interval : float
@export var base_effect : Effect 
	
func apply_status(target: Node) -> void: #trigger actual status effect 
	super.apply_status(target)
