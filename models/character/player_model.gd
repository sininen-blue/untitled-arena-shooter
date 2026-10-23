class_name PlayerModel
extends Node3D


@export var player: Player


var state_machine: AnimationNodeStateMachinePlayback
var applied_pose: String = ""


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tree: AnimationTree = $AnimationTree


func _ready() -> void:
	state_machine = tree["parameters/playback"]


func _process(_delta: float) -> void:
	if player == null:
		return
	_apply_pose()


func _apply_pose() -> void:
	var pose: String = _get_pose_from_state()

	if pose.is_empty():
		if applied_pose == "slide_enter":
			applied_pose = ""
		return
	if pose == applied_pose:
		return

	state_machine.start(pose)
	applied_pose = pose


func _get_pose_from_state() -> String:
	if player.wall_slide_side < 0:
		return "wall_slide_left"
	if player.wall_slide_side > 0:
		return "wall_slide_right"

	if player.is_jumping:
		if player.has_longgun:
			return "longgun_jump"
		if player.has_handgun:
			return "handgun_jump"

	elif player.is_sliding:
		return "slide_enter"

	elif player.is_running or player.is_walking:
		if player.has_longgun:
			return "longgun_run"
		if player.has_handgun:
			return "handgun_run"

	elif player.is_idle:
		if player.has_longgun:
			return "longgun_idle"
		if player.has_handgun:
			return "handgun_idle"
		return "idle"
	return ""
