extends Node
class_name ItemEffectManager

signal artifacts_updated()

@export var effect_manager : EffectManager

var artifacts : Array[ItemData] = []

func _ready() -> void:
	EventBus.on_upgrade_picked_up.connect(add_artifact)

func add_artifact(item : ItemData):
	artifacts.append(item)
	effect_manager.add_effects(effect_manager.effect_holder, item.ItemEffects)
	print ("Added artifact: " + item.ItemName)
	update_artifacts() 

func remove_artifact(item : ItemData):
	artifacts.erase(item)
	effect_manager.clear_effects(effect_manager.effect_holder, item.ItemEffects)
	update_artifacts()

func update_artifacts():
	artifacts_updated.emit() 
