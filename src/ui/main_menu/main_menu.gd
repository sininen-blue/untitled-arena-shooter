extends Control


@export var play_button_target: String


func _ready() -> void:
	pass


func _on_play_button_pressed() -> void:
	SceneLoader.load_scene(play_button_target)
