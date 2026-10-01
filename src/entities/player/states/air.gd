extends State

signal air_to_ground(force: float)

@export var speed: float = 8.0
@export var accel: float = 2.0
@export var deccel: float = 1.0

@export var player: Player
@export var idle_state: State
@export var walk_state: State
@export var slide_state: State
@export var run_state: State
@export var jump_state: State

@export var wall_slide_state: State
@export var wall_climb_state: State


var previous_y_velocity: float = 0


@onready var jump_input_handler: Node = %JumpInputHandler
@onready var wall_raycasts: WallRaycasts = %WallRaycasts


func enter() -> void:
	pass


func exit(new_state: State) -> void:
	if new_state.is_in_group("ground"):
		air_to_ground.emit(previous_y_velocity)


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * player.mass * delta
	
	if player.is_on_floor():
		if Input.is_action_pressed("crouch") and player.direction.length() > 0:
			state_machine.change_state(slide_state)
		elif Input.is_action_pressed("run") and player.direction.length() > 0:
			state_machine.change_state(run_state)
		elif player.direction.length() > 0:
			state_machine.change_state(walk_state)
		else:
			state_machine.change_state(idle_state)
	else:
		if wall_raycasts.is_colliding():
			if player.direction.length() > 0:
				if not state_machine.change_state(wall_climb_state):
					state_machine.change_state(wall_slide_state)
			else:
				state_machine.change_state(wall_slide_state)

	
	if jump_input_handler.consume():
		state_machine.change_state(jump_state)


	player.wish_velocity = player.direction * speed

	if player.direction.length() > 0:
		player.velocity.x = Utils.exp_decay(player.velocity.x, player.wish_velocity.x, accel, delta)
		player.velocity.z = Utils.exp_decay(player.velocity.z, player.wish_velocity.z, accel, delta)
	else:
		player.velocity.x = Utils.exp_decay(player.velocity.x, player.direction.x, deccel, delta)
		player.velocity.z = Utils.exp_decay(player.velocity.z, player.direction.z, deccel, delta)
	
	
	previous_y_velocity = player.velocity.y


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
