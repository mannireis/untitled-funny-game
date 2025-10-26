class_name Player
extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

var current_state := Idle

func _ready() -> void:
	State.player = self

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


@abstract class State:
	var player : CharacterBody2D

class Idle extends State:
	pass


class Dashing extends State:
	pass


class Jumping extends State:
	pass


class Climbing extends State:
	pass


class Falling extends State:
	pass
