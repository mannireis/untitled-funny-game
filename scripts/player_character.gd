class_name Player
extends CharacterBody2D

@export var dash_timer : Timer

var state: State = Idle.new()
var can_dash = true

func _ready() -> void:
	state.player = self

func _physics_process(delta: float) -> void:
	print(state)
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
	const SPEED := 110
	
	var player : CharacterBody2D
	
	var direction: Vector2:
		get():
			return Vector2(Input.get_axis("left", "right"), 
			Input.get_axis("up", "down")).normalized()

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
	func enter() -> void:
		player.can_dash = true
	
	func handle_input() -> State:
		if not player.is_on_floor():
			return Falling.new()
		
		if direction.x != 0:
			return Walking.new()
		
		if jump_input:
			return Jumping.new()
			
		if dash_input:
			return Dashing.new()

		return null
		
	func update(_delta: float) -> void:
		player.velocity.x = move_toward(player.velocity.x, 0, 50)


class Walking extends State:
	func enter() -> void:
		player.can_dash = true
	
	func handle_input() -> State:
		if direction.x == 0:
			return Idle.new()
		
		if jump_input:
			return Jumping.new()
	
		if not player.is_on_floor():
			return Falling.new()
			
		if dash_input:
			return Dashing.new()
		
		return null


	func update(_delta: float) -> void:
		player.velocity.x = direction.x * move_toward(150, SPEED, 50)


class Jumping extends State:
	const jump_force = -200
	
	func enter() -> void:
		player.velocity.y = jump_force


	func handle_input() -> State:
		if player.velocity.y >= 0:
			return Falling.new()

		if dash_input:
			return Dashing.new()
		return null
	
	
	func update(_delta: float) -> void:
		player.velocity.x = direction.x * SPEED

		player.velocity += player.get_gravity() * _delta


class Falling extends State:
	func handle_input() -> State:
		if player.is_on_floor():
			return Idle.new()
		if dash_input:
			return Dashing.new()
		return null
	
	
	func update(_delta: float) -> void:
		player.velocity.x = direction.x * SPEED
		player.velocity += player.get_gravity() * _delta


class Dashing extends State:
	const DASH_FORCE = 240
	const DASH_TIME = 0.03
	
	var is_dashing = false
	var dash_dir: Vector2 = Vector2.RIGHT
	var dash_timer = 0
	
	func update(_delta: float) -> void:
		if direction.x != 0:
			dash_dir.x = direction.x
			
		if player.can_dash:
			var final_dash_dir: Vector2 = dash_dir
			if direction.y != 0 and direction.x == 0:
				final_dash_dir.x = 0
			final_dash_dir.y = direction.y
			
			player.can_dash = false
			is_dashing = true
			dash_timer = DASH_TIME
			
			player.velocity = final_dash_dir * DASH_FORCE
			
		if is_dashing:
			dash_timer -= _delta
			if dash_timer <= 0:
				is_dashing = false
	
	
	func handle_input() -> State:
		if is_dashing == false:
			return Falling.new()
		return null


class Climbing extends State:
	pass
