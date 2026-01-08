extends PathFollow2D

@export var player : Player

func _ready() -> void:
	progress = 0

func _process(delta: float) -> void:
	progress += 100
