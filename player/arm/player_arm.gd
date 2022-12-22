extends RigidBody2D

var is_right_arm := false
var fade_alpha := 1.0

const FADE_BLUR_PARTICLE := preload("res://effects/fade_blur_particle/fade_blur_particle.tscn")

onready var sprite := $Sprite
onready var hitbox_collision := $Hitbox/CollisionShape2D

func _ready() -> void:
	GameEvent.emit_signal("add_action_object", self)
	
	hitbox_collision.disabled = true
	apply_torque_impulse(1500)

func _on_DeactivateHitboxTimer_timeout() -> void:
	# really crappy way of doing this
	# fix later, will lead to issues
	hitbox_collision.disabled = false

func instance_fade() -> void:
	fade_alpha *= 0.8
	var particle_instance := FADE_BLUR_PARTICLE.instance()
	
	particle_instance.texture = sprite.texture
	particle_instance.flip_h = sprite.flip_h
	particle_instance.scale = sprite.scale
	particle_instance.rotation = sprite.rotation
	particle_instance.global_position = global_position
	particle_instance.modulate.a = fade_alpha
	
	get_tree().current_scene.add_child(particle_instance)

func _exit_tree() -> void:
	GameEvent.emit_signal("remove_action_object", self)
