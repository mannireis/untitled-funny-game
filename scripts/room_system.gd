extends Area2D

@export var respawn_position : Vector2
@export var camera : RoomCamera
@export var camera_location : Node2D

var player_inside := false

func _physics_process(delta: float) -> void:
	if camera_location is Marker2D and player_inside:
		camera.actual_cam_pos = camera.actual_cam_pos.lerp(camera_location.global_position, delta * 10)
	
	if camera_location is Path2D and player_inside:
		pass
		


func _on_body_entered(player: Player) -> void:
	player.respawn_position == respawn_position
	player_inside = true


func _on_body_exited(body: Node2D) -> void:
	player_inside = false
