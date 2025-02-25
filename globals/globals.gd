extends Node

var player : Player :
	set(player_node):
		player = player_node

var rng : RandomNumberGenerator

@onready var event_bus = get_node("/root/EventBus")
