extends Camera2D
class_name RoomCamera

@export var room : Area2D

var actual_cam_pos : Vector2

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	actual_cam_pos = actual_cam_pos.lerp($"../player".position, delta * 3)
	
	var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
	
	Main.get_child(0).material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	
	global_position = actual_cam_pos.round()
