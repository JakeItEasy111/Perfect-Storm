extends Node3D
class_name InteractibleItem

@export var ItemHighlightMesh : MeshInstance3D

func GainFocus():
	ItemHighlightMesh.visible = true 
 
func LoseFocus():
	ItemHighlightMesh.visible = false 
