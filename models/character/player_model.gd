class_name PlayerModel
extends Node3D


@export var player: Player


var state_machine: AnimationNodeStateMachinePlayback
var applied_pose: String = ""


@onready var tree: AnimationTree = $AnimationTree


func _ready() -> void:
	state_machine = tree["parameters/playback"]


func _process(_delta: float) -> void:
	if player == null:
		return
	_apply_pose()


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
	if player.wall_slide_side < 0:
		return "wall_slide_left"
	if player.wall_slide_side > 0:
		return "wall_slide_right"

	if player.on_air:
		var jump: String = _jump_pose()

		if jump.is_empty():
			return _run_pose()

		return jump

	if player.on_ground:
		if player.is_sliding:
			return "slide"

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
	return ""
