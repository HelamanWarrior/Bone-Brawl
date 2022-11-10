extends KinematicBody2D

var velocity := Vector2(0, 0)
var speed := 500

func _physics_process(delta):
	velocity.x = Input.get_joy_axis(0, JOY_AXIS_0)
	
	move_and_slide(velocity * speed, Vector2.UP)
