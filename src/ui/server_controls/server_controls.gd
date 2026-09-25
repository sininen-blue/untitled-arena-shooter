extends Control

@export var start_game_target: StringName


func _on_start_server_pressed() -> void:
	NetworkManager.start_server()


func _on_join_game_pressed() -> void:
	NetworkManager.start_client()


func _on_start_game_pressed() -> void:
	SceneLoader.load_scene(start_game_target)
