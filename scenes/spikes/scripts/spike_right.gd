@tool
extends SpikeTemplate

var positions = [
	Vector2(0, 80),
	Vector2(8, 80),
	Vector2(16, 80)
]

func _ready() -> void:
	var random_index = randi() % positions.size()
	region_rect.position = positions[random_index]
