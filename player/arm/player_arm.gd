extends RigidBody2D

var is_right_arm := false
var fade_alpha := 1.0

const FADE_BLUR_PARTICLE := preload("res://effects/fade_blur_particle/fade_blur_particle.tscn")
const MIN_SPIN_SPEED := 600

onready var sprite := $Sprite
onready var hitbox_collision := $Hitbox/CollisionShape2D
onready var throw_animation_player := $ThrowAnimationPlayer
onready var spin_complete_timer := $SpinCompleteTimer

func _ready() -> void:
	GameEvent.emit_signal("add_action_object", self)
	
	hitbox_collision.disabled = true
	apply_torque_impulse(1500)

func _process(_delta: float) -> void:
	if sleeping:
		return
	
	if get_linear_velocity().length() < MIN_SPIN_SPEED:
		throw_animation_player.playback_speed = lerp(throw_animation_player.playback_speed, 0, 0.1)
		spin_complete_timer.wait_time = 0.8 * throw_animation_player.playback_speed
	else:
		throw_animation_player.play("throw")

func _on_SpinCompleteTimer_timeout() -> void:
	if throw_animation_player.playback_speed < 0.5:
		sprite.frame = 0
		throw_animation_player.stop()

func _on_DeactivateHitboxTimer_timeout() -> void:
	# really crappy way of doing this
	# fix later, will lead to issues
	hitbox_collision.disabled = false

func _exit_tree() -> void:
	GameEvent.emit_signal("remove_action_object", self)
