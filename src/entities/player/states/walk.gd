extends State

@export var speed: float = 10
@export var accel: float = 2.5

@export var player: Player
@export var air_state: State
@export var idle_state: State
@export var slide_state: State
@export var crouch_move_state: State
@export var run_state: State
@export var jump_state: State


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	if player.is_on_floor() == false:
		state_machine.change_state(air_state)
	if player.direction.length() <= 0:
		state_machine.change_state(idle_state)
	if Input.is_action_just_pressed("crouch"):
		state_machine.change_state(slide_state)
		state_machine.change_state(crouch_move_state)
	if Input.is_action_just_pressed("run"):
		state_machine.change_state(run_state)
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(jump_state)
	
	player.wish_velocity = player.direction * speed
	player.velocity = Utils.exp_decay(player.velocity, player.wish_velocity, accel, delta)


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
