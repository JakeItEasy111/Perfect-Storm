extends Effect
class_name StatusEffect

signal status_applied(status : StatusEffect)
signal status_changed()

enum StackType {NONE, INTENSITY, DURATION}

@export_group("Status Effect Data")
@export var id : String
@export var stack_type : StackType
@export var can_expire: bool
@export var duration: int : set = set_duration
@export var stacks : int : set = set_stacks
var active = false

@export_group("Visual Settings")
@export var visible : bool = false
@export var icon : Texture
@export var tooltip : String

func set_duration(new_duration): #change duration of status
	duration = new_duration
	status_changed.emit()

func add_duration(added_duration):
	duration += added_duration
	status_changed.emit()
	
func set_stacks(new_stacks): #change stack size 
	stacks = new_stacks
	status_changed.emit()

func apply_status(target: Node) -> void: #trigger actual status effect 
	status_applied.emit(self)
	
func on_status_removed(target: Node) -> void:
	status_changed.emit() 

func _has_status_handler(target : Node) -> bool:
	var children = target.get_children()
	for child in children:
		if child is StatusHandlerComponent:
			return true
	return false  
 
func execute(target : Node): #add this status to status handler
	if not (_has_status_handler(target)) : return

	target.status_handler_component.add_status(self)
