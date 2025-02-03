class_name HealthComponent
extends Node

signal health_changed(previous_health, new_health)
signal died

var has_died : bool = false 

var has_health_remaining : bool : 
	get:
		if current_health <= 0:
			return false
		else:
			return true 

@export var max_health : float = 100.0 :
	set(new_value):
		health_changed.emit(max_health, new_value) 
		max_health = new_value

@export var current_health : float = 100.0 :
	set(new_value):
		health_changed.emit(current_health, new_value)
		current_health = new_value
		if(!has_health_remaining and !has_died):
			has_died = true 
			died.emit() 
		
var health_percentage : float :
	get:
		if max_health > 0:
			return current_health / max_health
		else:
			return 0.0 
	set(new_value):
		health_percentage = new_value
		current_health = health_percentage * current_health

var damage_modifier : float = 0.0 
var heal_modifier : float = 0.0

func take_damage(amount):
	var final_damage
	if amount >= 0:
		final_damage = amount * (1.0 - damage_modifier)
	else:
		final_damage = amount * (1.0 - heal_modifier)
	current_health -= final_damage
	
func heal(amount):
	take_damage(-amount) 
