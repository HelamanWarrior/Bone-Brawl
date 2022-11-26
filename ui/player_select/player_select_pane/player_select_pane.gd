tool
extends TextureRect

export(int) var pane_number = 1

var player_number_textures := [
	preload("res://ui/player_numbers/p1.png"),
	preload("res://ui/player_numbers/p2.png"),
	preload("res://ui/player_numbers/p3.png"),
	preload("res://ui/player_numbers/p4.png")
]

var activated_texture := preload("res://ui/player_select/player_select_pane/pane.png")

onready var player_number := $PlayerNumber
onready var character := $Character
onready var controller := $Controller

func _ready() -> void:
	player_number.texture = player_number_textures[pane_number - 1]

func activate() -> void:
	character.visible = true
	controller.visible = true
	texture = activated_texture
	Global.chosen_connected_players.append(pane_number - 1)

func _input(event: InputEvent) -> void:
	if !event is InputEventJoypadButton:
		return
	
	if event.button_index == JOY_SELECT:
		get_tree().change_scene("res://arenas/prototype/prototype.tscn")
	
	# don't activate if currently active
	if character.visible == true:
		return
	
	if pane_number == event.device + 1:
		activate()
