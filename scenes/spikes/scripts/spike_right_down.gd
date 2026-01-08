@tool
extends SpikeTemplate

var positions = [
	Vector2(16, 88)
]

func _ready() -> void:
	var random_index = randi() % positions.size()
	region_rect.position = positions[random_index]
