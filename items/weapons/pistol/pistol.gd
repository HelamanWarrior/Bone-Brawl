extends RigidBody2D

const PistolData := preload("res://items/weapons/pistol/pistol_data.tres")

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		GameEvent.emit_signal("player_equip_item", area.get_parent(), PistolData)
		queue_free()
