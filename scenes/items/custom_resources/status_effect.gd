extends Effect
class_name StatusEffect

signal status_applied(status : StatusEffect)
signal status_changed()

enum Type {PERSISTENT, ON_HIT, ON_ACTION, WHILE_STILL, ON_ITEM_PICKUP, ON_ITEM_USE} 
enum StackType {NONE, INTENSITY, DURATION}

@export_group("Status Data")
@export var id : String
@export var type : Type
@export var stack_type : StackType
@export var can_expire: bool
@export var duration: int : set = set_duration
@export var stacks : int : set = set_stacks

@export_group("Visual Settings")
@export var icon : Texture
@export var tooltip : String

func set_duration(new_duration):
	duration = new_duration
	status_changed.emit()
	
func set_stacks(new_stacks):
	stacks = new_stacks
	status_changed.emit()
	
func initialize_status(_target: Node) -> void:
	pass

func apply_status(target: Node) -> void:
	execute(target)
	status_applied.emit(self)
 
