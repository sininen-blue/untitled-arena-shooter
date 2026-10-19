extends State


@export var jump_force: float = 6.0

@export var player: Player
@export var air_state: State


func enter() -> void:
	player.velocity += (player.get_floor_normal() + Vector3.UP).normalized() * jump_force
	player.jump_particle_spawner.request_spawn(player.global_position)
	state_machine.change_state(air_state)


func exit(_new_state: State) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
