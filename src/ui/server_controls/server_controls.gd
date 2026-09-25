extends Control

@export var start_game_target: StringName


func _on_start_game_pressed() -> void:
	SceneLoader.load_scene(start_game_target)
