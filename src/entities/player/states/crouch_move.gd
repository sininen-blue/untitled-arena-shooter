extends State


@export var speed: float = 5.0
@export var accel: float = 5.0

@export var player: Player
@export var walk_state: State
@export var crouch_state: State
@export var air_state: State
@export var jump_state: State


func enter() -> void:
	player.head.position.y = 0.5


func exit() -> void:
	player.head.position.y = 1.0


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	if player.is_on_floor() == false:
		state_machine.change_state(air_state)
	if player.direction.length() <= 0:
		state_machine.change_state(crouch_state)
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(jump_state)
	if Input.is_action_just_released("crouch"):
		state_machine.change_state(walk_state)
	
	player.wish_velocity = player.direction * speed
	player.velocity = Utils.exp_decay(player.velocity, player.wish_velocity, accel, delta)



func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
