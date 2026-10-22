class_name SettingsPanel
extends Panel


signal resumed


@onready var music_setting: SettingNumber = $Settings/Music
@onready var sfx_setting: SettingNumber = $Settings/Sfx


func _ready() -> void:
	music_setting.value = Config.get_setting("music_volume", 100.0)
	sfx_setting.value = Config.get_setting("sfx_volume", 100.0)


func _on_continue_button_pressed() -> void:
	resumed.emit()


func _on_sens_value_changed(value: float) -> void:
	Config.set_setting("sensitivity", value)


func _on_fov_value_changed(value: float) -> void:
	Config.set_setting("base_fov", value)


func _on_music_value_changed(value: float) -> void:
	Config.set_setting("music_volume", value)
	MusicPlayer.set_bus_volume("Music", value)


func _on_sfx_value_changed(value: float) -> void:
	Config.set_setting("sfx_volume", value)
	MusicPlayer.set_bus_volume("Sfx", value)
