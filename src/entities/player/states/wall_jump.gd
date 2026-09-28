extends State


@export var jump: float = 10
@export var horizontal_component: float = 2.0

@export var player: Player
@export var air_state: State


@onready var wall_raycasts: WallRaycasts = %WallRaycasts


func enter() -> void:
	var vertical := Vector3.UP
	var horizontal := wall_raycasts.get_wall_normal() * horizontal_component
	player.velocity += (vertical + horizontal).normalized() * jump


func exit(_new_state: State) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	if wall_raycasts.is_colliding() == false:
		state_machine.change_state(air_state)


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
