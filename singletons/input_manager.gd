extends Node

signal updated_input

var connected_gamepads := []

var keyboard_players := []

func _init() -> void:
	Input.connect("joy_connection_changed", self, "_joy_connection_changed")

func _ready() -> void:
	update_keyboard_players()

func _joy_connection_changed(_device: int, _connected: bool) -> void:
	connected_gamepads = Input.get_connected_joypads()
	print(connected_gamepads)
	print("Gamepad changed")
	update_keyboard_players()

func update_keyboard_players() -> void:
	var gamepad_numb := connected_gamepads.size()
	
	if gamepad_numb > 1:
		keyboard_players = []
		return
	
	keyboard_players = [0]
	
	emit_signal("updated_input")
