class_name  Player
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@export var mouse_sensitivity: float = 0.1


var twist_input: float = 0.0
var pitch_input: float = 0.0

var input_direction: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var wish_velocity: Vector3 = Vector3.ZERO

@onready var head: Node3D = %Head
@onready var camera: Camera3D = %Camera


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	if event is InputEventMouseMotion:
		twist_input -= event.screen_relative.x * mouse_sensitivity
		pitch_input -= event.screen_relative.y * mouse_sensitivity
		pitch_input = clampf(pitch_input, -85, 85)


func _process(delta: float) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	var twist_q = Quaternion(Vector3.UP, deg_to_rad(twist_input))
	var body_current_q = basis.get_rotation_quaternion()
	var smoothed_body_q = body_current_q.slerp(twist_q, delta * 50.0)
	basis = Basis(smoothed_body_q)
	
	var pitch_q = Quaternion(Vector3.RIGHT, deg_to_rad(pitch_input))
	var current_head_q = head.basis.get_rotation_quaternion()
	var smoothed_head_q = current_head_q.slerp(pitch_q, delta * 50.0)
	head.basis = Basis(smoothed_head_q)


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
