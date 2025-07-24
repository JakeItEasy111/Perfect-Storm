extends Node
class_name ItemEffectManager

signal artifacts_updated()

@export var effect_manager : EffectManager

var artifacts : Array[ItemData] = []

func add_artifact(item : ItemData):
	artifacts.append(item)
	effect_manager.add_effects(item.ItemEffects)
	update_artifacts() 

func remove_artifact(item : ItemData):
	artifacts.erase(item)
	effect_manager.clear_effects(item.ItemEffects)
	update_artifacts()

func update_artifacts():
	artifacts_updated.emit() 
