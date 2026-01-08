extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.allow_dash = true
		self.queue_free()
