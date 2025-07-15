extends Node3D

@export var music : AudioStream
@onready var coffee_item: InteractibleItem = $"../../../Items/CoffeeItem"

func _ready(): 
	AudioManager.play_music(music, SoundEffect.SOUND_EFFECT_TYPE.MUSIC_AMBIENT, 135.0)
