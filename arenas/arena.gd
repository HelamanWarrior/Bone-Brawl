extends Node2D

var player := preload("res://player/player.tscn")

onready var spawn_locations := [
	get_node("SpawnLocations/1"),
	get_node("SpawnLocations/2"),
	get_node("SpawnLocations/3"),
	get_node("SpawnLocations/4")
]

func _ready() -> void:
	for i in Global.chosen_connected_players:
		var player_instance: KinematicBody2D = player.instance()
		player_instance.global_position = spawn_locations[i].global_position
		player_instance.controller_num = i
		add_child(player_instance)
