class_name PlayerModel
extends Node3D


@export var player: Player


var state_machine: AnimationNodeStateMachinePlayback


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tree: AnimationTree = $AnimationTree


func _ready() -> void:
	state_machine = tree["parameters/playback"]


func play_idle() -> void:
	prints(
	"idle", player.is_idle, 
	"has_weapon", player.has_weapon, 
	"has_long", player.has_longgun, 
	"has_hand", player.has_handgun)
	
	if not player.is_idle:
		return
	
	if player.has_weapon:
		if player.has_longgun:
			state_machine.travel("longgun_idle")
		if player.has_handgun:
			state_machine.travel("handgun_idle")
	else:
		state_machine.travel("idle")
	print(state_machine.get_current_node())



func stop() -> void:
	state_machine.stop()
