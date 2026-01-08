class_name RoomSystem
extends Area2D

@export var respawn_position : Marker2D

var cam : Camera2D 
var player : Player
var player_inside := false

func _physics_process(delta: float) -> void:
	cam = %Camera2D
	if player_inside:
		cam.position = cam.position.lerp(global_position, 10 * delta)
		
	print(player_inside)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		player = body
		player.can_dash = true
		if respawn_position != null:
			player.respawn_position = respawn_position.global_position


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		player = null

#old code
#@onready var camera_path = $Path2D
#
#@export var respawn_position : Marker2D
#@export var next_room : RoomSystem
#
#var player : Player
#var camera_path_curve : Curve2D
#var player_inside := false
#var current_position = self.global_position
#var camera_follow : CameraFollow2D
#var closest_distance_to_player 
#
#func _ready() -> void:
	#camera_path_curve = Curve2D.new()
	#camera_path_curve.add_point(current_position)
	#camera_path_curve.add_point(next_room.global_position - position)
	#camera_path.curve = camera_path_curve
	#camera_follow.new()
	#closest_distance_to_player = player.global_position
#
#func _physics_process(delta: float) -> void:
	#camera_follow.progress = closest_distance_to_player
	#print(player_inside)
#
#
#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#player_inside = true
		#player = body
#
#
#func _on_body_exited(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#player_inside = false
		#player = null
