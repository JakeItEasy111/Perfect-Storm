extends Control

@onready var crosshair: TextureRect = $Crosshair
@onready var pda_hint: TextureRect = $PDAHint
@onready var action_progress_bar: TextureProgressBar = $ActionProgressBar
@onready var action_progress_timer: Timer = $ActionProgressBar/ActionProgressTimer
@onready var equipped_item : Node = Global.player.equipment_component

var can_charge = true
var charging = false 

func _ready() -> void:
	EventBus.connect("action_timer_begin", begin_action)
	EventBus.connect("action_timer_end", end_action)
	
func _process(delta: float) -> void:
	if charging:
		action_progress_bar.value = action_progress_timer.time_left
		if action_progress_bar.value <= 0: #later specify based on action 
			EventBus.action_timer_complete.emit()
			charging = false
	
func _on_player_pda_use(open) -> void:
	if(!open):
		self.hide()
	else:
		self.show()

func begin_action(duration):
	if can_charge and duration > 0:
		charging = true 
		action_progress_bar.tint_progress = Color.WHITE
		action_progress_bar.max_value = duration
		action_progress_bar.value = action_progress_bar.max_value
		action_progress_timer.wait_time = action_progress_bar.max_value
		action_progress_bar.show()
		action_progress_timer.start()
	
func end_action(cooldown):
	if can_charge and cooldown > 0:
		can_charge = false
		charging = false
		var progress_remaining = action_progress_bar.value
		action_progress_timer.stop()
		action_progress_bar.value = progress_remaining
		var tween = get_tree().create_tween()
		tween.tween_property(action_progress_bar, "tint_progress", Color(1, 0, 0, 0), cooldown)
		await get_tree().create_timer(cooldown).timeout
		action_progress_bar.hide()
		can_charge = true
