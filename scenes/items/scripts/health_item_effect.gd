@tool
extends ItemEffect
class_name HealthItemEffect

signal restore_player_health(value, duration)

@export var heal_value : int
@export var heal_time : float #0  = instantaneous heal

func apply_effect(player):
	super.apply_effect(player)
	
func heal_property(player):
	pass #connect to health component, perhaps extend health component for a player-specific component
	
