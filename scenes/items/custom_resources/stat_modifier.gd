extends Resource
class_name StatModifier 

enum StatModifierType {
 ADD,
 SUB,
 MULT,
 DIVIDE,
 PERCENT_ADD,
 PERCENT_MULT,
 PERCENT_DIVIDE,
}

@export var type : StatModifierType 
@export var value : float  

func initialize(_value : float, _type : StatModifierType) -> void:
	value = _value
	type = +type
