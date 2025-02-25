extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var gui = $GUI

func _on_player_pda_use(open) -> void:
	if(!open):
		self.visible = true
		anim_player.play("PDA_Equip")
		await anim_player.animation_finished
		gui.visible = true 
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		gui.visible = false 
		anim_player.play_backwards("PDA_Equip2")
		await anim_player.animation_finished
		self.visible = false 
