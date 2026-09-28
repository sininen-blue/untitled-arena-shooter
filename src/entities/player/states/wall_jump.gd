extends State


@export var jump: float = 10

@export var player: Player
@export var air_state: State


@onready var wall_raycasts: WallRaycasts = %WallRaycasts


func enter() -> void:
	player.velocity += (Vector3.UP + wall_raycasts.get_wall_normal()).normalized() * jump


func exit() -> void:
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
