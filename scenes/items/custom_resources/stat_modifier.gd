extends Resource
class_name StatModifier 

enum Type {
	HEALING,
	STAMINA_RECOVERY,
	DAMAGE,
	ACTION_SPEED,
	MOVEMENT_SPEED, 
} 

@export var type : Type 
@export var modifier : float  
