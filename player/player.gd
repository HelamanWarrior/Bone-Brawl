extends KinematicBody2D

export(int) var controller_num = 0

var velocity := Vector2(0, 0)
var speed := 500
var jump_speed := 1000

func _physics_process(delta):
	var input_x := Input.get_joy_axis(controller_num, JOY_AXIS_0)
	
	if abs(input_x) < Global.DEADZONE:
		velocity.x = 0
	else:
		velocity.x = input_x * speed
	
	velocity.y += Global.gravity
	
	if Input.is_joy_button_pressed(controller_num, JOY_BUTTON_0) and is_on_floor():
		velocity.y = -jump_speed
	
	velocity = move_and_slide(velocity, Vector2.UP)
