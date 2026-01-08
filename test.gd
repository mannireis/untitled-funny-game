class_name TestRoom
extends Area2D

@export var respawn_position : Marker2D

var player : Player
var player_inside := false

func _physics_process(delta: float) -> void:
	if player_inside:
		var cam := $"../Camera2D"
		cam.position = cam.position.lerp(global_position, 20 * delta)
		
	print(player_inside)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		player = null
