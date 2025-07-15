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

@export_group("Visual Settings")
@export var visible : bool = false
@export var icon : Texture
@export var tooltip : String

func set_duration(new_duration): #change duration of status
	duration = new_duration
	status_changed.emit()
	
func set_stacks(new_stacks): #change stack size 
	stacks = new_stacks
	status_changed.emit()
	
func initialize_status(_target: Node) -> void: #upon adding the status 
	pass

func apply_status(target: Node) -> void: #trigger actual status effect 
	status_applied.emit(self)
	
func on_status_removed(target: Node) -> void:
	status_changed.emit() 
 
func execute(target): #add this status to status handler
	if target is Player: 
		target.add_status(self)
