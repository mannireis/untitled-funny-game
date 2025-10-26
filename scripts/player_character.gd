class_name Player
extends CharacterBody2D

var state: State = Idle.new()

func _ready() -> void:
	state.player = self

func _physics_process(delta: float) -> void:
	var new_state = state.handle_input()
	
	if new_state != null:
		var old_state = state
		old_state.exit()
		new_state.player = self
		new_state.enter()
		state = new_state
	
	state.update(delta)
	move_and_slide()


@abstract class State:
	const SPEED := 300
	
	var player : CharacterBody2D
	
	var direction: float:
		get():
			return Input.get_axis("move_left", "move_right")
	
	var jump_input: bool:
		get():
			return Input.is_action_just_pressed("jump")
	
	var dash_input: bool:
		get():
			return Input.is_action_just_pressed("dash")
	
	var climb_input: bool:
		get:
			return Input.is_action_pressed("climb")
	
	func enter() -> void:
		pass

	func exit() -> void:
		pass
		
	func handle_input() -> State:
		return
	
	func update(_delta: float) -> void:
		pass

class Idle extends State:
	func handle_input() -> State:
		if not player.is_on_floor():
			return Falling.new()
		
		if direction != 0:
			return Walking.new()
		
		if jump_input:
			return Jumping.new()

		return null
		
	func update(_delta: float) -> void:
		player.velocity.x = 0

class Walking extends State:
	func handle_input() -> State:
		if direction == 0:
			return Idle.new()
		
		if jump_input:
			return Jumping.new()
		
		if not player.is_on_floor():
			return Falling.new()
		return null


	func update(_delta: float) -> void:
		player.velocity.x = direction * SPEED

class Jumping extends State:
	const jump_force = -400
	
	func enter() -> void:
		player.velocity.y = jump_force
	
	
	func handle_input() -> State:
		if player.velocity.y >= 0:
			return Falling.new()
		
		return null
	
	
	func update(_delta: float) -> void:
		player.velocity.x = direction * SPEED
		player.velocity += player.get_gravity() * _delta

class Falling extends State:
	func handle_input() -> State:
		if player.is_on_floor():
			return Idle.new()
		return null
	
	
	func update(_delta: float) -> void:
		player.velocity.x = direction * SPEED
		player.velocity += player.get_gravity() * _delta

class Dashing extends State:
	pass

class Climbing extends State:
	pass
