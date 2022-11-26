extends KinematicBody2D

export(int) var controller_num = 0
var using_keyboard := false

enum states {DEFAULT, WALL_SLIDE, HIT, DEATH}
var current_state = states.DEFAULT

var velocity := Vector2(0, 0)
var speed := 650
var current_jumps := 0
var just_pressed_jump := false

const JUMP_SPEED := 1000
const MAX_JUMPS := 1

onready var sprite := $Sprite
onready var wall_check_raycast := $WallCheck

func _init() -> void:
	InputManager.connect("updated_input", self, "_updated_input")

func _physics_process(_delta: float) -> void:
	match current_state:
		states.DEFAULT:
			var input := movement_input_handling()
			animation_handling(input)
			jump_handling()
			
			velocity.x = input.x * speed
			velocity.y += Global.gravity
			
			velocity = move_and_slide(velocity, Vector2.UP)
			check_for_wall_jump(input)
			
		states.WALL_SLIDE:
			var input := movement_input_handling()
			
			if input.x > 0:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
			
			jump_handling()
			
			velocity.x = input.x * speed
			velocity.y = min(velocity.y + 50, 175)
			
			velocity = move_and_slide(velocity, Vector2.UP)
			check_for_wall_jump(input)

func movement_input_handling() -> Vector2:
	var input := movement_raw_input()
	
	if input.length() < Global.DEADZONE:
		return Vector2(0, 0)
	
	return input

func movement_raw_input() -> Vector2:
	var axis := Vector2(Input.get_joy_axis(controller_num, JOY_AXIS_0), Input.get_joy_axis(controller_num, JOY_AXIS_1))
	if axis.length() < Global.DEADZONE:
		axis.x = int(Input.is_joy_button_pressed(controller_num, JOY_DPAD_RIGHT)) - int(Input.is_joy_button_pressed(controller_num, JOY_DPAD_LEFT))
	
	return axis

func jump() -> void:
	velocity.y = -JUMP_SPEED
	current_jumps -= 1

func jump_handling() -> void:
	if current_jumps > 0:
		check_for_jump()
	
	check_for_jump_regen()

func check_for_jump() -> void:
	# TODO figure out just pressed function
	if Input.is_joy_button_pressed(controller_num, JOY_BUTTON_0):
		if !just_pressed_jump:
			jump()
			just_pressed_jump = true
	else:
		just_pressed_jump = false

func check_for_jump_regen() -> void:
	if is_on_floor():
		current_jumps = MAX_JUMPS

func check_for_wall_jump(input: Vector2) -> void:
	if !wall_check_raycast.is_colliding():
		if current_state == states.WALL_SLIDE:
			current_state = states.DEFAULT
		
		return
	
	var sliding_left: bool = wall_check_raycast.cast_to.x > 0 and input.x > 0
	var sliding_right: bool = wall_check_raycast.cast_to.x < 0 and input.x < 0
	
	if sliding_left or sliding_right:
		current_jumps = MAX_JUMPS
		
		if Input.is_joy_button_pressed(controller_num, JOY_BUTTON_0):
			current_state = states.WALL_SLIDE
			print("WALL SLIDE")
	else:
		current_state = states.DEFAULT
		print("DEFAULT")

func animation_handling(input: Vector2) -> void:
	if input.x > 0:
		sprite.flip_h = true
		wall_check_raycast.cast_to.x = 35
		return
	
	if input.x != 0:
		sprite.flip_h = false
		wall_check_raycast.cast_to.x = -35

func check_for_wall_slide() -> void:
	pass

func _updated_input() -> void:
	if !InputManager.keyboard_players.has(controller_num):
		using_keyboard = false
		return
	
	using_keyboard = true
