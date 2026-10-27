class_name SettingsPage
extends Control


@export var back_button_target: StringName


func _on_back_button_pressed() -> void:
	SceneLoader.load_scene(back_button_target)
