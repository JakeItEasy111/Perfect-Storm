extends Node3D

var open = false

@onready var player = get_parent() 
@onready var anim_player = $AnimationPlayer
@onready var gui = $Arms_Rig/Skeleton3D/PDA/GUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_player_pda_use() -> void:
	if(!open):
		self.visible = true
		anim_player.play("PDA_Equip")
		open = true; 
		await anim_player.animation_finished
		gui.visible = true 
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		gui.visible = false 
		anim_player.play_backwards("PDA_Equip2")
		await anim_player.animation_finished
		self.visible = false 
		open = false; 
