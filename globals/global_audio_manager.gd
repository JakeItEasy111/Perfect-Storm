extends Node3D

#signals
signal sound_effect_played(type)

# SFX Variables 
@export var sound_effect_dict : Dictionary[SoundEffect.SOUND_EFFECT_TYPE, SoundEffect]

# Volumes 
var master_volume : int 
var music_volume : int
var sfx_volume : int

# Music Variables
var music_audio_player_count : int = 2 
var current_music_player : int = 0 
var music_players : Array [ AudioStreamPlayer ] = [] 
var music_bus : String = "Music" #name of bus 
var music_fade_duration : float = 2.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in music_audio_player_count:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = music_bus 
		music_players.append(player)

### MUSIC ###

func play_music(_audio : AudioStream, type : SoundEffect.SOUND_EFFECT_TYPE, start_pos : float = 0.0) -> void:
	if _audio == music_players[current_music_player].stream:
		return
	
	current_music_player += 1
	if current_music_player > music_audio_player_count - 1:
		current_music_player = 0
	
	var current_player : AudioStreamPlayer = music_players[current_music_player]
	current_player.volume_db = sound_effect_dict[type].volume
	current_player.pitch_scale = sound_effect_dict[type].pitch_scale
	current_player.stream = _audio
	play_fade_in(current_player, start_pos)
	
	var old_player = music_players[1]
	if current_music_player == 1: 
		old_player = music_players[0]
	stop_fade_out(old_player)

func play_fade_in(player : AudioStreamPlayer, start_pos : float = 0.0) -> void:
	var volume = player.volume_db
	player.volume_db = -40
	player.play(start_pos)
	var tween : Tween = create_tween()
	tween.tween_property(player, 'volume_db', volume, music_fade_duration)

func stop_fade_out(player: AudioStreamPlayer, start_pos : float = 0.0) -> void: 
	var tween : Tween = create_tween()
	tween.tween_property(player, 'volume_db', -40, music_fade_duration)
	await tween.finished
	player.stop()

### SOUND EFFECTS ###

func play_3d_audio_at_location(location : Node, type : SoundEffect.SOUND_EFFECT_TYPE, sound_index : int = -1): 
	if sound_effect_dict.has(type):
		var sound_effect_setting : SoundEffect = sound_effect_dict[type]
		if sound_effect_setting.has_open_limit():
			sound_effect_setting.change_audio_count(1)
			var new_3d_audio = AudioStreamPlayer3D.new()
			location.add_child(new_3d_audio)
			
			if sound_index == -1:
				sound_index = randi_range(0, sound_effect_setting.sound_effect_array.size() - 1)
				
			new_3d_audio.stream = sound_effect_setting.sound_effect_array[sound_index]
			new_3d_audio.bus = sound_effect_setting.bus
			new_3d_audio.volume_db = sound_effect_setting.volume
			new_3d_audio.pitch_scale = sound_effect_setting.pitch_scale
			new_3d_audio.pitch_scale += randf_range(-sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)
			new_3d_audio.finished.connect(sound_effect_setting.on_audio_finished)
			new_3d_audio.finished.connect(new_3d_audio.queue_free)
			await get_tree().process_frame
			new_3d_audio.play()
			sound_effect_played.emit(type)

	else:
		push_error("Sound Effect Type does not exist")
	
func play_audio(type : SoundEffect.SOUND_EFFECT_TYPE, sound_index : int = -1):
	if sound_effect_dict.has(type):
		var sound_effect_setting : SoundEffect = sound_effect_dict[type]
		if sound_effect_setting.has_open_limit():
			sound_effect_setting.change_audio_count(1)
			var new_audio = AudioStreamPlayer.new()
			add_child(new_audio)
			
			if sound_index == -1:
				sound_index = randi_range(0, sound_effect_setting.sound_effect_array.size() - 1)
			
			new_audio.stream = sound_effect_setting.sound_effect_array[sound_index]
			new_audio.bus = sound_effect_setting.bus
			new_audio.volume_db = sound_effect_setting.volume
			new_audio.pitch_scale = sound_effect_setting.pitch_scale
			new_audio.pitch_scale += randf_range(-sound_effect_setting.pitch_randomness, sound_effect_setting.pitch_randomness)
			new_audio.finished.connect(sound_effect_setting.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.play() 
			sound_effect_played.emit(type)
	else:
		push_error("Sound Effect Type does not exist")
