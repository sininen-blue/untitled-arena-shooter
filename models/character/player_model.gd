class_name PlayerModel
extends Node3D


signal head_hit(damage: float, source: Area3D)
signal body_hit(damage: float, source: Area3D)


const Y_STRAIGHT: float = 1.0
const Y_UP: float = 5.0
const Y_DOWN: float = -5.0


@export var player: Player


var state_machine: AnimationNodeStateMachinePlayback
var applied_pose: String = ""

@onready var tree: AnimationTree = $AnimationTree
@onready var skeleton: Skeleton3D = $Player/Skeleton3D

@onready var marker: Marker3D = $HeadMarker
@onready var hand_marker: Marker3D = $HandMarker

@onready var player_one_attach: BoneAttachment3D = $Player/Skeleton3D/PlayerOneAttach
@onready var player_one_head: MeshInstance3D = $Player/Skeleton3D/PlayerOneAttach/PlayerOneHead
@onready var player_one_body: MeshInstance3D = $Player/Skeleton3D/PlayerOneBody
@onready var player_two_attach: BoneAttachment3D = $Player/Skeleton3D/PlayerTwoAttach
@onready var player_two_head: MeshInstance3D = $Player/Skeleton3D/PlayerTwoAttach/PlayerTwoHead
@onready var player_two_body: MeshInstance3D = $Player/Skeleton3D/PlayerTwoBody


func _ready() -> void:
	tree.active = true
	state_machine = tree["parameters/playback"]
	skeleton.skeleton_updated.connect(_on_skeleton_updated)
	_apply_body_variant()


func _apply_body_variant() -> void:
	var use_one := _body_variant() == 0
	player_one_attach.visible = use_one
	player_one_head.visible = use_one
	player_one_body.visible = use_one
	player_two_attach.visible = not use_one
	player_two_head.visible = not use_one
	player_two_body.visible = not use_one


func _body_variant() -> int:
	var peer_id: int = _peer_id()
	var index: int = NetworkManager.players.keys().find(peer_id)

	if index <= 0:
		return 0
	if index == 1:
		return 1

	return absi(hash(peer_id)) % 2


func _peer_id() -> int:
	if player == null or not player.name.is_valid_int():
		return 0
	return player.name.to_int()


func _process(_delta: float) -> void:
	if player == null:
		return
		
	marker.position.y = _pitch_to_marker_y(player.pitch_degrees)
	hand_marker.position.y = _pitch_to_marker_y(player.pitch_degrees)
	_apply_pose()
	_end_throw_if_finished()


func get_right_hand_global_position() -> Vector3:
	if not is_inside_tree() or skeleton == null or not skeleton.is_inside_tree():
		return Vector3.ZERO
	var bone_pose := skeleton.get_bone_global_pose(21)
	return (skeleton.global_transform * bone_pose).origin


func get_hand_look_global_position() -> Vector3:
	if hand_marker == null or not hand_marker.is_inside_tree():
		return Vector3.ZERO
	return hand_marker.global_position


func _on_skeleton_updated() -> void:
	if player == null or not is_inside_tree():
		return
	player.align_gun_to_hand_look()


func _apply_pose() -> void:
	var pose := _get_pose_from_state()
	if pose.is_empty() or pose == applied_pose:
		return
	if state_machine.get_current_node() == pose:
		applied_pose = pose
		return

	state_machine.travel(pose)
	applied_pose = pose


func _get_pose_from_state() -> String:
	if player.is_throwing:
		return _throw_pose()

	if player.wall_slide_side < 0:
		return _wall_slide_pose(true)
	if player.wall_slide_side > 0:
		return _wall_slide_pose(false)

	if player.on_air:
		return _jump_pose()

	if player.on_ground:
		if player.is_sliding:
			return "slide"

		if player.is_crouching:
			if player.is_walking:
				return _crouch_walk_pose()
			return _crouch_idle_pose()

		if player.is_running or player.is_walking:
			return _run_pose()

		if player.is_idle:
			return _idle_pose()

	return ""


func _run_pose() -> String:
	if player.has_longgun:
		return "longgun_run"
	if player.has_handgun:
		return "handgun_run"
	return "run"


func _idle_pose() -> String:
	if player.has_longgun:
		return "longgun_idle"
	if player.has_handgun:
		return "handgun_idle"
	return "idle"


func _jump_pose() -> String:
	if player.has_longgun:
		return "longgun_jump"
	if player.has_handgun:
		return "handgun_jump"
	return "jump"


func _crouch_idle_pose() -> String:
	if player.has_longgun:
		return "crouch_longgun_idle"
	if player.has_handgun:
		return "crouch_handgun_idle"
	return "crouch"


func _crouch_walk_pose() -> String:
	if player.has_longgun:
		return "crouch_longgun_walk"
	if player.has_handgun:
		return "crouch_handgun_walk"
	return "crouch_walk"


func _wall_slide_pose(left: bool) -> String:
	return "wall_slide_left" if left else "wall_slide_right"


func _throw_pose() -> String:
	if player.wall_slide_side < 0:
		return "wall_slide_left_throw"
	if player.wall_slide_side > 0:
		return "wall_slide_right_throw"
	if player.is_crouching:
		return "crouch_throw_idle"
	if player.is_running or player.is_walking:
		return "run_throw"
	return "idle_throw"


func _end_throw_if_finished() -> void:
	if not player.is_throwing or not player.is_multiplayer_authority():
		return
	if not _is_throw_pose(state_machine.get_current_node()):
		return
	var length := state_machine.get_current_length()
	if length <= 0.0:
		return
	if state_machine.get_current_play_position() >= length:
		player.is_throwing = false


func _is_throw_pose(pose: StringName) -> bool:
	return pose in [
		"idle_throw",
		"run_throw",
		"crouch_throw_idle",
		"wall_slide_left_throw",
		"wall_slide_right_throw",
	]


func _pitch_to_marker_y(pitch_degrees: float) -> float:
	pitch_degrees = clampf(pitch_degrees, -85.0, 85.0)
	if pitch_degrees >= 0.0:
		return remap(pitch_degrees, 0.0, 85.0, Y_STRAIGHT, Y_UP)
	return remap(pitch_degrees, 0.0, -85.0, Y_STRAIGHT, Y_DOWN)


func _on_hurtbox_hit(damage: float, source: Area3D) -> void:
	head_hit.emit(damage, source)


func _on_head_hurtbox_hit(damage: float, source: Area3D) -> void:
	body_hit.emit(damage, source)
