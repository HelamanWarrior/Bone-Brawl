extends Node

const DEADZONE := 0.2
const GAME_WIDTH := 1920
const GAME_HEIGHT := 1080

var gravity := 75

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
