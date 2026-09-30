extends State


@export var drag: float = 8.0

@export var player: Player
@export var air_state: State
@export var idle_state: State
@export var jump_state: State
@export var crouch_move_state: State


@onready var jump_input_handler: Node = %JumpInputHandler


func enter() -> void:
	player.head_target.position.y = 0.5


func exit(_new_state: State) -> void:
	player.head_target.position.y = 1.0


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	if player.is_on_floor() == false:
		state_machine.change_state(air_state)
	if player.direction.length() > 0:
		state_machine.change_state(crouch_move_state)
	if Input.is_action_just_released("crouch"):
		state_machine.change_state(idle_state)
	if jump_input_handler.consume():
		state_machine.change_state(jump_state)
	
	player.velocity = Utils.exp_decay(player.velocity, Vector3.ZERO, drag, delta)


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
