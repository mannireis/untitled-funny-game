class_name Player
extends CharacterBody2D

@onready var animation_player = %AnimatedSprite2D
@onready var coyote_timer = %CoyoteTimer
@onready var jump_buffer_timer = %JumpBufferTimer

var state: State = Idle.new()
var can_dash := true
var can_grapple := true
var respawn_position: Vector2
var max_wall_time := 3
var on_wall := false
var wall_normal := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	state.player = self
	state.grapple = %grapple


func _physics_process(delta: float) -> void:
	if %RayCast2D.is_colliding() or %RayCast2D2.is_colliding():
		on_wall = true
	else:
		on_wall = false
	
	if %RayCast2D2.is_colliding():
		wall_normal = Vector2.LEFT
	elif %RayCast2D.is_colliding():
		wall_normal = Vector2.LEFT
	
	print(on_wall)
	
	var new_state = state.handle_input()

	if new_state != null:
		var old_state = state
		old_state.exit()
		new_state.player = self
		new_state.grapple = %grapple
		new_state.enter()
		state = new_state
	
	print(state.get_script().resource_path)
	print(%grapple.position)
	
	update_squash(delta)
	update_hair()
	state.update(delta)
	move_and_slide()


func update_squash(delta: float):

	if velocity.y > 100:
		animation_player.scale.y = move_toward(1, 3, 10 * delta)
		animation_player.scale.x = move_toward(1, 0.6, 10 * delta)
	
	if state is Dashing and state.direction.x:
		animation_player.scale.y = move_toward(1, 0.5, 20 * delta)
		animation_player.scale.x = move_toward(1, 3, 20 * delta)

	if state is Dashing and state.direction.y:
		animation_player.scale.y = move_toward(1, 3, 20 * delta)
		animation_player.scale.x = move_toward(1, 0.6, 20 * delta)

	if state is Jumping:
		animation_player.scale.y = move_toward(1, 1.2, 20 * delta)
		animation_player.scale.x = move_toward(1, 0.8, 20 * delta)
	
	animation_player.scale.x = move_toward(animation_player.scale.x, 1, 3 * delta)
	animation_player.scale.y = move_toward(animation_player.scale.y, 1, 3 * delta)


func update_hair():
	var hair_color_1: Color = Color("#1ebc73")
	var hair_color_2: Color = Color("#239063")
	var hair_color_1_new: Color = Color("#533b41")
	var hair_color_2_new: Color = Color("#3c252b")

	var mat: Material = animation_player.material

	if mat is ShaderMaterial:
		if can_dash:
			mat.set_shader_parameter("from_color_1", hair_color_1)
			mat.set_shader_parameter("to_color_1", hair_color_1)
			mat.set_shader_parameter("from_color_2", hair_color_2)
			mat.set_shader_parameter("to_color_2", hair_color_2)
		else:
			mat.set_shader_parameter("from_color_1", hair_color_1)
			mat.set_shader_parameter("to_color_1", hair_color_1_new)
			mat.set_shader_parameter("from_color_2", hair_color_2)
			mat.set_shader_parameter("to_color_2", hair_color_2_new)


@abstract class State:
	const SPEED := 90
	
	var player : CharacterBody2D
	var grapple : Area2D
	
	var direction: Vector2:
		get():
			return Vector2(Input.get_axis("left", "right"), 
			Input.get_axis("up", "down"))

	var jump_input: bool:
		get():
			return Input.is_action_just_pressed("jump")
	
	var dash_input: bool:
		get():
			return Input.is_action_just_pressed("dash")
	
	var grapple_input: bool:
		get():
			return Input.is_action_just_pressed("grapple")
	
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
		player.max_wall_time == 3
	
	func handle_input() -> State:
		if not player.is_on_floor():
			player.coyote_timer.start()
			return Falling.new()
		
		if direction.x != 0:
			return Walking.new()
		
		if jump_input:
			player.jump_buffer_timer.start()
			if player.is_on_floor() and not player.jump_buffer_timer.is_stopped():
				return Jumping.new()
			
		if dash_input and Globals.allow_dash:
			return Dashing.new()
		
		if player.on_wall and !player.is_on_floor():
			return Climbing.new()
		
		#if grapple_input:
			#return Grappling.new()

		return null
		
	func update(_delta: float) -> void:
		if !player.animation_player.is_playing():
			player.animation_player.play("idle")
		player.velocity.x = move_toward(player.velocity.x, 0, 70)


class Walking extends State:
	func enter() -> void:
		player.can_dash = true
		player.max_wall_time == 3
	
	func handle_input() -> State:
		if direction.x == 0:
			player.animation_player.play("walk_switch")
			return Idle.new()
		
		if jump_input:
			player.jump_buffer_timer.start()
			if player.is_on_floor() and not player.jump_buffer_timer.is_stopped():
				return Jumping.new()
	
		if not player.is_on_floor():
			player.coyote_timer.start()
			return Falling.new()
			
		if player.on_wall and !player.is_on_floor():
			return Climbing.new()
		
		if dash_input and Globals.allow_dash:
			return Dashing.new()
		
		return null
		


	func update(_delta: float) -> void:
		if direction.x < 0:
			player.animation_player.flip_h = true
		if direction.x > 0:
			player.animation_player.flip_h = false
		player.animation_player.play("walk")
		player.velocity.x = direction.x * move_toward(150, SPEED, 50)


class Jumping extends State:
	const jump_force = -200
	const push_force = 20 

	var wall_jump_lock := 0.0
	var min_jump_time := 0.1

	
	func enter() -> void:
		min_jump_time = 0.1

		if player.wall_normal != Vector2.ZERO and !player.is_on_floor():
			player.velocity.y = jump_force
			player.velocity.x = player.wall_normal.x * push_force
			wall_jump_lock = 0.15
			
		elif player.is_on_floor():
			player.velocity.y = jump_force

	func handle_input() -> State:
		if min_jump_time > 0:
			return null

		if player.velocity.y >= 0:
			return Falling.new()

		if dash_input and Globals.allow_dash:
			return Dashing.new()

		if player.on_wall and !player.is_on_floor():
			return Climbing.new()
			
		return null

	func update(delta: float) -> void:
		
		if direction.x < 0:
			player.animation_player.flip_h = true
		elif direction.x > 0:
			player.animation_player.flip_h = false

		if !player.animation_player.is_playing():
			player.animation_player.play("jump_up")

		if player.velocity.y <= 0 and Input.is_action_just_released("jump"):
			player.velocity.y *= 0.3

		if wall_jump_lock > 0:
			wall_jump_lock -= delta
		else:
			player.velocity.x = direction.x * SPEED

		min_jump_time -= delta
		player.velocity += player.get_gravity() * delta


class Falling extends State:
	const gravity = 100
	
	func handle_input() -> State:
		if not player.coyote_timer.is_stopped() and jump_input:
			return Jumping.new()

		if player.is_on_floor():
			player.animation_player.play("land")
			return Idle.new()
			
		if player.on_wall and !player.is_on_floor():
			return Climbing.new()
			
		if dash_input and Globals.allow_dash:
			return Dashing.new()
		
		if jump_input and player.velocity.x == 0 and player.on_wall:
			return Jumping.new()
	
		return null
	
	func update(_delta: float) -> void:
		if direction.x < 0:
			player.animation_player.flip_h = true
		if direction.x > 0:
			player.animation_player.flip_h = false

		player.animation_player.play("fall")
		if player.velocity.x == 0:
			player.velocity.x = direction.x * SPEED
		player.velocity += player.get_gravity() * _delta


class Dashing extends State:
	const DASH_FORCE := 240
	const DASH_TIME := 0.15

	var dash_dir := Vector2.ZERO
	var dash_timer := 0.0
	var is_dashing := false

	func enter() -> void:
		if player.can_dash:
			player.animation_player.play("dash")
			is_dashing = true
			dash_timer = DASH_TIME
			player.can_dash = false

			dash_dir = direction.normalized()

			if dash_dir == Vector2.ZERO:
				if player.animation_player.flip_h:
					dash_dir = Vector2.LEFT
				else:
					dash_dir = Vector2.RIGHT

			player.velocity = dash_dir * DASH_FORCE

	func update(_delta: float) -> void:
		if is_dashing:
			dash_timer -= _delta
			player.velocity = dash_dir * DASH_FORCE 
			if dash_timer <= 0:
				is_dashing = false
		
		if dash_dir.y and dash_dir.x == 0:
			player.velocity += player.get_gravity() * _delta * 3

		player.velocity += player.get_gravity() * _delta

	func handle_input() -> State:
		if not is_dashing:
			return Falling.new()
		return null


class Climbing extends State:
	var climb_speed := 60
	const WALL_SLIDE_SPEED := 40
	
	func handle_input() -> State:
		if player.is_on_floor():
			return Idle.new()
		
		if jump_input:
			return Jumping.new()
			
		if player.on_wall == false:
			return Falling.new()
			
		if dash_input and Globals.allow_dash:
			return Dashing.new()
		return null
	
	func update(_delta: float) -> void:
		
		player.velocity.x = 0
		
		player.velocity.x = direction.x * SPEED
		
		if player.velocity.y > WALL_SLIDE_SPEED:
			player.velocity.y = WALL_SLIDE_SPEED
		else:
			player.velocity += player.get_gravity() * _delta


#class Grappling extends State:
	#const GRAPPLE_FORCE := 240
	#const GRAPPLE_TIME := 0.15
#
	#var grapple_dir := Vector2.ZERO
	#var grapple_timer := 0.0
	#var is_grappling := false
#
	#func enter() -> void:
		#if player.can_grapple:
			##player.animation_player.play("dash")
			#is_grappling = true
			#grapple_timer = GRAPPLE_TIME
			#player.can_grapple = false
#
			#grapple_dir = direction.normalized()
#
			#if grapple_dir == Vector2.ZERO:
				#if player.animation_player.flip_h:
					#grapple_dir = Vector2.LEFT
				#else:
					#grapple_dir = Vector2.RIGHT
			##grapple.velocity = grapple_dir * GRAPPLE_FORCE
#
	#func update(_delta: float) -> void:
		#if player.can_grapple:
			#grapple.position += grapple_dir * GRAPPLE_FORCE * _delta
#
		#if is_grappling:
			#grapple_timer -= _delta
			#grapple.position += grapple_dir * GRAPPLE_FORCE * _delta
			##grapple.velocity = grapple_dir * GRAPPLE_FORCE
			#if grapple_timer <= 0:
				#is_grappling = false
		#
		##if grapple_dir.y and grapple_dir.x == 0:
			##grapple.linear_velocity += grapple.get_gravity() * _delta * 3
##
		##grapple.linear_velocity += grapple.get_gravity() * _delta
#
	#func handle_input() -> State:
		#if not is_grappling:
			#return Falling.new()
		#return null
#
#
	#func exit() -> void:
		#grapple.position = grapple.position.move_toward(player.position, 10)


func _on_death_body_entered(body: Node2D) -> void:
	hide()
	await get_tree().create_timer(0.3).timeout
	position = respawn_position
	show()
	
