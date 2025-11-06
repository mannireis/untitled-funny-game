@tool
extends Area2D

@export var respawn_position : Vector2
@export var camera : Camera
@export var camera_location : Node2D

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if camera_location is Marker2D:
		camera.actual_cam_pos = camera.actual_cam_pos.lerp(camera_location.global_position, delta * 10)
	
	if camera_location is Path2D:
		pass
	
	elif camera_location == null:
		print("wath the fuck you what are you trying")
