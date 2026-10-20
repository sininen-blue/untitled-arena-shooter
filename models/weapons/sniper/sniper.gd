extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_test_sniper_shot() -> void:
	animation_player.play("Animation")
