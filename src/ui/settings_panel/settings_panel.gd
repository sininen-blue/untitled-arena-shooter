class_name SettingsPanel
extends Panel


signal resumed


func _on_continue_button_pressed() -> void:
	resumed.emit()


func _on_sens_value_changed(value: float) -> void:
	Config.set_setting("sensitivity", value)


func _on_fov_value_changed(value: float) -> void:
	Config.set_setting("base_fov", value)
