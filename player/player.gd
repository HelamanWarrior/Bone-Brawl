extends KinematicBody2D

export(int) var controller_num = 0
var using_keyboard := false

var velocity := Vector2(0, 0)
var speed := 650
var current_jumps := 0

const JUMP_SPEED := 1500
const MAX_JUMPS := 1

onready var sprite := $Sprite

func _init() -> void:
	InputManager.connect("updated_input", self, "_updated_input")

func _physics_process(_delta: float) -> void:
	var input := movement_raw_input()
	
	if input.length() < Global.DEADZONE:
		input = Vector2(0, 0)
	
	animation_handling(input)
	
	velocity.x = input.x * speed
	velocity.y += Global.gravity
	
	if current_jumps > 0:
		check_for_jump()
	
	check_for_jump_regen()
	
	#screen_wrap()
	velocity = move_and_slide(velocity, Vector2.UP)

func movement_raw_input() -> Vector2:
	if InputManager.keyboard_players.size() > 0 and controller_num == 0:
		return Vector2(
			Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")
		)
	
	return Vector2(
		Input.get_joy_axis(controller_num, JOY_AXIS_0), 
		Input.get_joy_axis(controller_num, JOY_AXIS_1)
	)

func screen_wrap() -> void:     
	if global_position.x > Global.GAME_WIDTH:
		global_position.x = 0
		return
	
	if global_position.x < 0:
		global_position.x = Global.GAME_WIDTH
		return

func jump() -> void:
	velocity.y = -JUMP_SPEED
	current_jumps -= 1

func check_for_jump() -> void:
	if using_keyboard:
		if Input.is_action_just_pressed("jump"):
			jump()
		return
	
	# TODO figure out just pressed function
	if Input.is_joy_button_pressed(controller_num, JOY_BUTTON_0):
		jump()

func check_for_jump_regen() -> void:
	if is_on_floor():
		current_jumps = MAX_JUMPS

func animation_handling(input: Vector2) -> void:
	if input.x > 0:
		sprite.flip_h = true
		return
	
	if input.x != 0:
		sprite.flip_h = false

func _updated_input() -> void:
	if !InputManager.keyboard_players.has(controller_num):
		return
	
	using_keyboard = true
