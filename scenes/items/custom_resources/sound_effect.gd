class_name SoundEffect
extends Resource

enum SOUND_EFFECT_TYPE { #add new types here 
	FOOTSTEP_CONCRETE,
	ALARM_SOUND,
	ITEM_PICKUP,
	MUSIC_AMBIENT,
}

@export var type : SOUND_EFFECT_TYPE
@export var bus : String = "Master"
@export var sound_effect_array : Array[AudioStream]
@export_range(0, 10) var limit : int = 1 
@export_range(-40, 20) var volume = 0
@export_range(0.0, 4.0, .01) var pitch_scale = 1.0
@export_range(0.0, 1.0, .01) var pitch_randomness = 0.0

var audio_count = 0 

func change_audio_count(amount : int):
	audio_count = max(0, audio_count + amount)
	
func has_open_limit() -> bool:
	return audio_count < limit

func on_audio_finished():
	change_audio_count(-1)
