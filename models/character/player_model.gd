class_name PlayerModel
extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_idle() -> void:
	animation_player.play("idle")


func stop() -> void:
	animation_player.stop()
