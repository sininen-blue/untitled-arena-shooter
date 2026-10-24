class_name PlayerModel
extends Node3D


@export var player: Player


var state_machine: AnimationNodeStateMachinePlayback
var applied_pose: String = ""


@onready var tree: AnimationTree = $AnimationTree
@onready var skeleton: Skeleton3D = $Player/Skeleton3D


func _ready() -> void:
	tree.active = true
	state_machine = tree["parameters/playback"]


func _process(_delta: float) -> void:
	if player == null:
		return
	_apply_pose()
	_end_throw_if_finished()


func get_right_hand_global_position() -> Vector3:
	var bone_pose := skeleton.get_bone_global_pose(21)
	return (skeleton.global_transform * bone_pose).origin


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
