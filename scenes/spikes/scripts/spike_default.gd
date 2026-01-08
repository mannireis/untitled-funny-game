@tool
extends SpikeTemplate

var positions = [
	Vector2(0, 88),
	Vector2(8, 88)
]

func _ready() -> void:
	var random_index = randi() % positions.size()
	region_rect.position = positions[random_index]
