extends State

@export var drag: float = 5

@export var player: Player
@export var air_state: State
@export var walk_state: State
@export var run_state: State
@export var crouch_state: State
@export var jump_satte: State


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	if player.is_on_floor() == false:
		state_machine.change_state(air_state)
	
	if Input.is_action_pressed("run") and player.direction.length() > 0:
		state_machine.change_state(run_state)
	elif player.direction.length() > 0:
		state_machine.change_state(walk_state)
	
	if Input.is_action_just_pressed("crouch"):
		state_machine.change_state(crouch_state)
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(jump_satte)

	player.velocity = Utils.exp_decay(player.velocity, Vector3.ZERO, drag, delta)


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
