extends KinematicBody2D

export(int) var controller_num = 0
var using_keyboard := false

enum states {DEFAULT, WALL_SLIDE, HIT, DEATH}
var current_state = states.DEFAULT

var velocity := Vector2(0, 0)
var speed := 650
var current_jumps := 0
var just_pressed_jump := false
var just_pressed_throw := false

const JUMP_SPEED := 1250
const MAX_JUMPS := 1
const RAYCAST_LENGTH := 35
const SLIDE_ACCELERATION := 50
const MAX_SLIDE_SPEED := 175
const MIN_ARM_HURT_FORCE := 600

var player_number_textures := [
	preload("res://ui/player_numbers/p1.png"),
	preload("res://ui/player_numbers/p2.png"),
	preload("res://ui/player_numbers/p3.png"),
	preload("res://ui/player_numbers/p4.png")
]

var arm := preload("res://player/arm/player_arm.tscn")

onready var body_sprite := $Body
onready var arm_sprites := [$RightArm, $LeftArm]
onready var wall_check_raycast := $WallCheck
onready var player_number := $PlayerNumber
onready var hit_flash_timer := $HitFlashTimer

func _init() -> void:
	InputManager.connect("updated_input", self, "_updated_input")

func _ready() -> void:
	GameEvent.emit_signal("add_action_object", self)
	player_number.texture = player_number_textures[controller_num]
	
	_updated_input()

func _physics_process(_delta: float) -> void:
	match current_state:
		states.DEFAULT:
			var input := movement_input_handling()
			animation_handling(input)
			jump_handling()
			arm_throw_handling()
			
			velocity.x = input.x * speed
			velocity.y += Global.gravity
			
			velocity = move_and_slide(velocity, Vector2.UP)
			check_for_wall_jump(input)
			
		states.WALL_SLIDE:
			var input := movement_input_handling()
			
			# direction opposite of wall
			if input.x > 0:
				change_sprite_direction(false)
			else:
				change_sprite_direction(true)
			
			jump_handling()
			arm_throw_handling()
			
			velocity.x = input.x * speed
			velocity.y = min(velocity.y + SLIDE_ACCELERATION, MAX_SLIDE_SPEED)
			
			velocity = move_and_slide(velocity, Vector2.UP)
			check_for_wall_jump(input)

func movement_input_handling() -> Vector2:
	var input := movement_raw_input()
	
	if input.length() < Global.DEADZONE:
		return Vector2(0, 0)
	
	return input

func movement_raw_input() -> Vector2:
	if using_keyboard:
		return Vector2(Input.get_axis("left", "right"), 0)
	
	var axis := Vector2(Input.get_joy_axis(controller_num, JOY_AXIS_0), Input.get_joy_axis(controller_num, JOY_AXIS_1))
	
	if axis.length() < Global.DEADZONE:
		axis.x = int(Input.is_joy_button_pressed(controller_num, JOY_DPAD_RIGHT)) - int(Input.is_joy_button_pressed(controller_num, JOY_DPAD_LEFT))
	
	return axis

func arm_throw_handling() -> void:
	if using_keyboard:
		if !Input.is_action_pressed("throw_left") and !Input.is_action_pressed("throw_right"):
			just_pressed_throw = false
			return
	else:
		if !Input.is_joy_button_pressed(controller_num, JOY_L2) and !Input.is_joy_button_pressed(controller_num, JOY_R2):
			just_pressed_throw = false
			return
	
	if just_pressed_throw:
		return
	
	just_pressed_throw = true
	
	if Input.is_joy_button_pressed(controller_num, JOY_L2) or (using_keyboard and Input.is_action_pressed("throw_left")):
		if arm_sprites[0].visible:
			arm_sprites[0].visible = false
			instance_arm()
			return
		
	if Input.is_joy_button_pressed(controller_num, JOY_R2) or (using_keyboard and Input.is_action_pressed("throw_right")):
		if arm_sprites[1].visible:
			arm_sprites[1].visible = false
			var right_arm := instance_arm()
			right_arm.is_right_arm = true
			return

func instance_arm() -> Object:
	var arm_instance := arm.instance()
	arm_instance.global_position = global_position
	arm_instance.get_node("Hitbox").add_to_group("player_arm")
	arm_instance.get_node("Hitbox").add_to_group(str(controller_num))
	get_tree().current_scene.add_child(arm_instance)
	
	var direction := 1
	
	if !body_sprite.flip_h:
		direction = -1
	
	arm_instance.sprite.flip_h = body_sprite.flip_h
	
	arm_instance.apply_central_impulse(Vector2(1250 * direction, -250))
	arm_instance.angular_velocity = 15 * direction
	return arm_instance

func jump() -> void:
	velocity.y = -JUMP_SPEED
	current_jumps -= 1

func jump_handling() -> void:
	if current_jumps > 0:
		check_for_jump()
	
	check_for_jump_regen()

func check_for_jump() -> void:
	if using_keyboard:
		if Input.is_action_pressed("jump"):
			if !just_pressed_jump:
				jump()
				just_pressed_jump = true
		else:
			just_pressed_jump = false
		
		return
	
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
		
		if !is_on_floor():
			current_state = states.WALL_SLIDE
	else:
		current_state = states.DEFAULT

func animation_handling(input: Vector2) -> void:
	if input.x > 0:
		change_sprite_direction(true)
		wall_check_raycast.cast_to.x = RAYCAST_LENGTH
		return
	
	if input.x != 0:
		change_sprite_direction(false)
		wall_check_raycast.cast_to.x = -RAYCAST_LENGTH

func change_sprite_direction(flip: bool) -> void:
	body_sprite.flip_h = flip
	arm_sprites[0].flip_h = flip
	arm_sprites[1].flip_h = flip

func _updated_input() -> void:
	if controller_num != 0:
		using_keyboard = false
		return
	
	if InputManager.connected_gamepads.size() == 0:
		using_keyboard = true
		return
	
	using_keyboard = false

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_arm"):
		var arm_belongs_to_player := area.is_in_group(str(controller_num))
		var arm := area.get_parent()
		
		if arm_belongs_to_player:
			if arm.is_right_arm:
				arm_sprites[1].visible = true
			else:
				arm_sprites[0].visible = true
			
			arm.queue_free()
		else:
			if arm.linear_velocity.length() > MIN_ARM_HURT_FORCE:
				# replace with actual sprite later
				modulate = Color(50, 50, 50)
				hit_flash_timer.start()
				arm.linear_velocity = -arm.linear_velocity * 0.4

func _on_HitFlashTimer_timeout() -> void:
	# reset to default sprite later
	modulate = Color(1, 1, 1)

func _exit_tree() -> void:
	GameEvent.emit_signal("remove_action_object", self)
