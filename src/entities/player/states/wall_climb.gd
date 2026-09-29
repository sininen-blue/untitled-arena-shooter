extends State


@export var speed: float = 3.0
@export var accel: float = 2.0
@export var drag: float = 1.0

@export var wall_climb_strength: float = 3.5
@export var wall_climb_duration: float = 0.75
@export var wall_climb_curve: Curve

@export var player: Player
@export var air_state: State
@export var wall_slide_state: State
@export var wall_jump_state: State

@export var idle_state: State
@export var walk_state: State
@export var run_state: State


var time: float = 0.0
var current_wall_climb_strength: float = 0.0


@onready var wall_raycasts: WallRaycasts = %WallRaycasts


func enter() -> void:
	if player.velocity.y < 0:
		if state_machine.previous_state == wall_slide_state:
			player.velocity.y = 0
		else:
			player.velocity.y = player.velocity.y / 4
	else:
		player.velocity.y = player.velocity.y / 2


func exit(new_state: State) -> void:
	if new_state.is_in_group("ground"):
		time = 0


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	if wall_raycasts.front_is_colliding() == false:
		if wall_raycasts.is_colliding():
			if not state_machine.change_state(wall_slide_state):
				state_machine.change_state(air_state)
		else:
			state_machine.change_state(air_state)

	if player.is_on_floor():
		if player.direction.length() > 0:
			if Input.is_action_pressed("run"):
				state_machine.change_state(run_state)
			else:
				state_machine.change_state(walk_state)
		else:
			state_machine.change_state(idle_state) 
	
	if time > wall_climb_duration and wall_raycasts.is_colliding():
		state_machine.change_state(wall_slide_state)

	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(wall_jump_state)
	
	
	current_wall_climb_strength = wall_climb_curve.sample(time/wall_climb_duration) * wall_climb_strength
	if Input.is_action_pressed("move_forward"):
		time += 1 * delta
		player.velocity.y += current_wall_climb_strength * delta
	else:
		player.velocity += player.get_gravity() * player.mass/2 * delta

	player.wish_velocity = player.direction * speed

	if player.direction.length() > 0:
		player.velocity.x = Utils.exp_decay(player.velocity.x, player.wish_velocity.x, accel, delta)
		player.velocity.z = Utils.exp_decay(player.velocity.z, player.wish_velocity.z, accel, delta)
	else:
		player.velocity.x = Utils.exp_decay(player.velocity.x, player.direction.x, drag, delta)
		player.velocity.z = Utils.exp_decay(player.velocity.z, player.direction.z, drag, delta)


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	if wall_raycasts.front_is_colliding() and time == 0:
		return true
	return false
