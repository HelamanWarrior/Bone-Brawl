extends Sprite

func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, 0, 0.2)
	
	if modulate.a < 0.05:
		queue_free()
