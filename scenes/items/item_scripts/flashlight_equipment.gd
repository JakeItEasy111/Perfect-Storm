extends Node3D

@onready var light: SpotLight3D = $Light
@onready var flare: Sprite3D = $Flare

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		if light.visible:
			light.hide() 
			flare.hide()
		else:
			light.show()
			flare.show() 
