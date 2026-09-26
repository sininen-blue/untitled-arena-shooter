extends State


@export var jump_force: float = 5

@export var player: Player
@export var air_state: State


func enter() -> void:
	player.velocity.y = jump_force
	state_machine.change_state(air_state)


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	if player.is_on_floor():
		return true
	else:
		return false
