@tool
extends SpikeTemplate

var positions = [
	Vector2(0, 72),
	Vector2(8, 72),
	Vector2(16, 72)
]

func _ready() -> void:
	var random_index = randi() % positions.size()
	region_rect.position = positions[random_index]
