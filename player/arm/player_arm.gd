extends RigidBody2D

var is_right_arm := false

onready var sprite := $Sprite
onready var hitbox_collision := $Hitbox/CollisionShape2D

func _ready() -> void:
	hitbox_collision.disabled = true

func _on_DeactivateHitboxTimer_timeout() -> void:
	# really crappy way of doing this
	# fix later, will lead to issues
	hitbox_collision.disabled = false
