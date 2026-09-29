class_name  Player
extends CharacterBody3D


signal interacted(player: Player)


@export var mouse_sensitivity: float = 0.1

@export var mass: float = 2.0

@export var wall_climb_state: State
@export var wall_slide_state: State


## NOTE: DEBUG
@export var health: float = 4


var current_weapon: HitscanWeapon


var twist_input: float = 0.0
var pitch_input: float = 0.0

var input_direction: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var wish_velocity: Vector3 = Vector3.ZERO


@onready var head: Node3D = %Head
@onready var camera: Camera3D = %Camera
@onready var hand_marker: Marker3D = $HandMarker


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	
	camera.current = true


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("interact"):
		interacted.emit(self)


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
	
	
	## NOTE: DEBUG
	if Input.is_action_pressed("shoot") and current_weapon:
		current_weapon.shoot()
	
	# NOTE: put this in a compenent
	if self.is_on_floor():
		wall_climb_state.time = 0
		wall_slide_state.time = 0
	
	var twist_q = Quaternion(Vector3.UP, deg_to_rad(twist_input))
	var body_current_q = basis.get_rotation_quaternion()
	var smoothed_body_q = body_current_q.slerp(twist_q, delta * 40.0)
	basis = Basis(smoothed_body_q)
	
	var pitch_q = Quaternion(Vector3.RIGHT, deg_to_rad(pitch_input))
	var current_head_q = head.basis.get_rotation_quaternion()
	var smoothed_head_q = current_head_q.slerp(pitch_q, delta * 40.0)
	head.basis = Basis(smoothed_head_q)


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (self.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	move_and_slide()


func get_speed() -> float:
	return self.velocity.length()


@rpc("any_peer", "call_local", "reliable")
func take_damage(damage: float) -> void:
	health -= damage
	if health <= 0:
		self.queue_free.call_deferred()


func get_weapon(weapon_instance: HitscanWeapon) -> void:
	current_weapon = weapon_instance
	hand_marker.add_child(weapon_instance)


func drop_weapon() -> void:
	pass
