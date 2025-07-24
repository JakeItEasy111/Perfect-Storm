extends Condition
class_name StatThresholdCondition

enum COMPARISON_TYPE {LESS_THAN, GREATER_THAN, LESS_THAN_EQUAL, GREATER_THAN_EQUAL, EQUAL}
@export var comparison : COMPARISON_TYPE
@export var stat : Stat 
@export var variable_name : String
@export var threshold_percentage : int 

func check(target : Node) -> bool:
	match comparison:
		COMPARISON_TYPE.LESS_THAN:
			if stat.adjusted_value < threshold_percentage:
				return true
		COMPARISON_TYPE.GREATER_THAN:
			if stat.adjusted_value > threshold_percentage:
				return true
		COMPARISON_TYPE.LESS_THAN_EQUAL:
			if stat.adjusted_value <= threshold_percentage:
				return true
		COMPARISON_TYPE.GREATER_THAN_EQUAL:
			if stat.adjusted_value >= threshold_percentage:
				return true
		COMPARISON_TYPE.EQUAL: 
			if stat.adjusted_value == threshold_percentage:
				return true
	return false 
