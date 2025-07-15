class_name HealthComponent
extends Node

signal health_changed(previous_health, new_health)
signal died

var has_died : bool = false 
var can_regen : bool = true

var health_ui: Label #TEMP

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
		
		if current_health > 100.0:
			current_health = 100.0
		
		if(!has_health_remaining and !has_died):
			has_died = true 
			died.emit() 
		
var health_percentage : float :
	get:
		return (current_health / max_health) * 100
	set(new_percentage):
		current_health = (new_percentage / 100) * max_health

var damage_modifier : float = 0.0 
var heal_modifier : float = 0.0

func _ready() -> void: #temporary 
	health_ui =  get_node("/root/" + get_tree().current_scene.name + "/PlayerUI/TempHP")
	health_ui.text = str(current_health)
	
func update_health_UI():
	health_ui.text = str(current_health)
	
func damage(amount):
	var final_damage
	if amount >= 0:
		final_damage = amount * (1.0 - damage_modifier)
	else:
		final_damage = amount * (1.0 - heal_modifier)
	current_health -= final_damage
	
	update_health_UI()
	
func heal_flat(amount):
	damage(-amount) 

func damage_percent(percent):
	var final_damage 
	if percent >= 0:
		final_damage = percent * (1.0 - damage_modifier)
	else:
		final_damage = percent * (1.0 - heal_modifier)
	
	health_percentage = health_percentage - final_damage
	
	update_health_UI()
	
func heal_percent(amount):
	damage_percent(-amount)

func damage_over_time(tick_amount, ticks, tick_rate, flat):
	for n in ticks:
		await get_tree().create_timer(tick_rate).timeout
		if tick_amount < 0 and !can_regen:
			break
		else:
			if flat:
				damage(tick_amount)
			else:
				damage_percent(tick_amount)
		

func regen(tick_amount, time, rate, flat):
	damage_over_time(-tick_amount, time, rate, flat)
