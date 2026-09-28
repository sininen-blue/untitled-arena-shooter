extends State


@export var speed: float = 10.0
@export var accel: float = 2.0
@export var deccel: float = 1.0

@export var player: Player
@export var idle_state: State
@export var walk_state: State
@export var run_state: State
@export var jump_state: State


@onready var jump_input_handler: Node = %JumpInputHandler


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * player.mass * delta
	
	if player.is_on_floor():
		if Input.is_action_pressed("run") and player.direction.length() > 0:
			state_machine.change_state(run_state)
		elif player.direction.length() > 0:
			state_machine.change_state(walk_state)
		else:
			state_machine.change_state(idle_state)
	
	if jump_input_handler.consume():
		state_machine.change_state(jump_state)


	player.wish_velocity = player.direction * speed

	if player.direction.length() > 0:
		player.velocity.x = Utils.exp_decay(player.velocity.x, player.wish_velocity.x, accel, delta)
		player.velocity.z = Utils.exp_decay(player.velocity.z, player.wish_velocity.z, accel, delta)
	else:
		player.velocity.x = Utils.exp_decay(player.velocity.x, player.direction.x, deccel, delta)
		player.velocity.z = Utils.exp_decay(player.velocity.z, player.direction.z, deccel, delta)


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
