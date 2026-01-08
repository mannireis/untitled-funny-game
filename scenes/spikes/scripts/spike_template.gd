class_name SpikeTemplate
extends Sprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hide()
		body.position = body.respawn_position
		body.show()
