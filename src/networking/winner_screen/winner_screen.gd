class_name WinnerScreen
extends Label


signal finished()



@onready var animation_player: AnimationPlayer = $AnimationPlayer


func start() -> void:
	animation_player.play("win")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	finished.emit()
