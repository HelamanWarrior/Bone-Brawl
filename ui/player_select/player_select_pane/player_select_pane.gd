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
onready var deactivated_texture := texture

onready var player_number := $PlayerNumber
onready var character := $Character
onready var controller := $Controller
onready var join_instructions := $JoinInstructions

func _ready() -> void:
	player_number.texture = player_number_textures[pane_number - 1]

func toggle(activate: bool) -> void:
	character.visible = activate
	controller.visible = activate
	join_instructions.visible = !activate
	player_number.visible = activate
	
	if activate:
		texture = activated_texture
		Global.chosen_connected_players.append(pane_number - 1)
		return
	
	texture = deactivated_texture
	Global.chosen_connected_players.erase(pane_number - 1)

func _input(event: InputEvent) -> void:
	if !event is InputEventJoypadButton:
		return
	
	if event.button_index == JOY_SELECT:
		get_tree().change_scene("res://arenas/prototype/prototype.tscn")
	
	# controller button event has to corespond with the correct pane
	if pane_number != event.device + 1:
		return
	
	if event.button_index == JOY_XBOX_B:
		toggle(false)
		return
	
	# don't activate if already active
	if character.visible == true:
		return
	
	if event.button_index == JOY_XBOX_A:
		toggle(true)
