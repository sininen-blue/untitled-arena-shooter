@tool
class_name SettingNumber
extends HBoxContainer


signal value_changed(value: float)


@export var title: String = "Setting":
	set = _set_title
@export var value: float = 10.0:
	set = _set_value


@onready var setting_title: Label = $SettingTitle
@onready var setting_value: AnimatedLineEdit = $SettingValue


func _ready() -> void:
	setting_title.text = title
	setting_value.text = str(value)


func _set_title(new_val: String) -> void:
	title = new_val

	if setting_title and Engine.is_editor_hint():
		setting_title.text = str(title)


func _set_value(new_val: float) -> void:
	value = new_val

	value_changed.emit(value)

	if setting_value and Engine.is_editor_hint():
		setting_value.text = str(value)


func _on_setting_value_text_changed(new_text: String) -> void:
	if float(new_text) == 0.0:
		value = 0.0
	else:
		value = float(new_text)
