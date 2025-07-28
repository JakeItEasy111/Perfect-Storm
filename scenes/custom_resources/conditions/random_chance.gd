extends Condition
class_name RandomChanceCondition

@export var chance : float

func check(context : EventContext) -> bool:
	var result = randf() * 100
	if result <= chance:
		return true
	return false 
