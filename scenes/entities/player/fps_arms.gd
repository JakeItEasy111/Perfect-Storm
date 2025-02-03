extends Node3D

var open = false

@onready var anim_player = $AnimationPlayer
@onready var gui = $GUI

func _on_player_pda_use() -> void:
	if(!open):
		open = true; 
		self.visible = true
		anim_player.play("PDA_Equip")
		await anim_player.animation_finished
		gui.visible = true 
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		open = false; 
		gui.visible = false 
		anim_player.play_backwards("PDA_Equip2")
		await anim_player.animation_finished
		self.visible = false 
		open = false; 
