extends State


@export var entry_boost: float = 10.0
@export var entry_boost_cooldown: float = 1.2
@export var turn_weight: float = 2.0

@export var max_slide_speed: float = 40.0
@export var slide_boost: float = 5.0

@export var speed_threshold: float = 5.0
@export var speed_threshold_angle_modifier_curve: Curve

@export var slide_drag_curve: Curve
@export var drag_angle_modifier_curve: Curve

@export var player: Player
@export var air_state: State
@export var jump_state: State
@export var idle_state: State
@export var crouch_state: State
@export var crouch_move_state: State
@export var walk_state: State
@export var run_state: State


var time: float = 0.0
var time_sample_point: float = 0.0

var current_drag: float = 0.0
var current_speed_threshold: float = 0.0

var is_going_down: bool = false
var drag_angle_modifier: float = 0.0
var angle_sample_point: float = 0.0

var slided_wish_velocity: Vector3
var new_velocity_direction: Vector3
var new_velocity_length: float


@onready var jump_input_handler: Node = %JumpInputHandler
@onready var boost_cooldown_timer: Timer = $BoostCooldownTimer


func _ready() -> void:
	time = 0
	boost_cooldown_timer.wait_time = entry_boost_cooldown



func enter() -> void:
	player.head.position.y = 0.25

	if boost_cooldown_timer.is_stopped():
		player.velocity += player.velocity.normalized() * entry_boost
		boost_cooldown_timer.start()


func exit() -> void:
	player.head.position.y = 1.0


func update(delta: float) -> void:
	time += 1 * delta


func physics_update(delta: float) -> void:
	if player.is_on_floor() == false:
		state_machine.change_state(air_state)

	if jump_input_handler.consume():
		state_machine.change_state(jump_state)

	if player.velocity.length() < current_speed_threshold:
		if player.direction.length() > 0:
			if Input.is_action_pressed("run"):
				state_machine.change_state(run_state)
			elif Input.is_action_pressed("crouch"):
				state_machine.change_state(crouch_move_state)
			else:
				state_machine.change_state(walk_state)
		else:
			if Input.is_action_pressed("crouch"):
				state_machine.change_state(crouch_state)
			else:
				state_machine.change_state(idle_state)
	
	if Input.is_action_just_released("crouch"):
		if player.direction.length() > 0:
			if Input.is_action_pressed("run"):
				state_machine.change_state(run_state)
			else:
				state_machine.change_state(walk_state)
		else:
			state_machine.change_state(idle_state)
	
	is_going_down = player.velocity.dot(player.get_floor_normal())> 0

	if is_going_down and player.velocity.length() < max_slide_speed:
		player.velocity += player.velocity.normalized() * slide_boost* delta
	
	if is_going_down:
		angle_sample_point = player.get_floor_angle() / player.floor_max_angle
	else:
		angle_sample_point = 0.0
	
	drag_angle_modifier = drag_angle_modifier_curve.sample(angle_sample_point)
	current_speed_threshold = speed_threshold_angle_modifier_curve.sample(angle_sample_point) * speed_threshold

	current_drag = slide_drag_curve.sample(time) * drag_angle_modifier
	player.wish_velocity = player.direction

	new_velocity_length = Utils.exp_decay(player.velocity, Vector3.ZERO, current_drag, delta).length()
	if player.get_floor_normal() != Vector3.ZERO:
		slided_wish_velocity = player.wish_velocity.slide(player.get_floor_normal().normalized())
	new_velocity_direction = Utils.exp_decay(player.velocity.normalized(), slided_wish_velocity, turn_weight, delta)

	player.velocity = new_velocity_direction * new_velocity_length



func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
