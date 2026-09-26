extends State


@export var boost: float = 10.0
@export var boost_cooldown: float = 1.2
@export var turn_weight: float = 2.0

@export var speed_threshold: float = 5.0
@export var speed_threshold_angle_modifier: Curve

@export var slide_drag_curve: Curve
@export var drag_angle_modifier: Curve

@export var player: Player
@export var air_state: State
@export var idle_state: State
@export var crouch_state: State
@export var crouch_move_state: State
@export var walk_state: State
@export var run_state: State


func enter() -> void:
	player.head.position.y = 0.5


func exit() -> void:
	player.head.position.y = 1.0


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
