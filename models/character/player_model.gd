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
	
	if player.is_idle:
		_apply_idle_pose()


func _apply_idle_pose() -> void:
	var pose: String = "idle"

	if player.has_longgun:
		pose = "longgun_idle"
	elif player.has_handgun:
		pose = "handgun_idle"

	if pose == applied_pose:
		return

	state_machine.start(pose)
	applied_pose = pose
