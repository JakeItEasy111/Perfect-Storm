extends Node3D
class_name InteractibleItem

@export var ItemHighlightMesh : MeshInstance3D
@export var ItemQuantity : int = 1

func GainFocus():
	ItemHighlightMesh.visible = true 
 
func LoseFocus():
	ItemHighlightMesh.visible = false 
