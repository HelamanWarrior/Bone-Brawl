tool
extends ColorRect

export(int) var pane_number = 1

const CHARACTER_TEXTURES := [
	preload("res://player/PlayerSelect/Bones.png"),
	preload("res://player/PlayerSelect/Tall.png"),
	preload("res://player/PlayerSelect/Berserk.png"),
	preload("res://player/PlayerSelect/Fat.png")
]

const PLAYER_COLORS := [Color("#552c72"), Color("#4e5945"), Color("#2a435e"), Color("#813a2e")]

onready var character := $Character
onready var join_instructions := $JoinInstructions

func _ready() -> void:
	var player_index_number: int = pane_number - 1
	
	color = PLAYER_COLORS[player_index_number]
	character.texture = CHARACTER_TEXTURES[player_index_number]
	
	Global.chosen_connected_players = []

func toggle(activate: bool) -> void:
	character.visible = activate
	join_instructions.visible = !activate
	
	if activate:
		#texture = activated_texture
		Global.chosen_connected_players.append(pane_number - 1)
		return
	
	#texture = deactivated_texture
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
