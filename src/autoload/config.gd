extends Node


signal setting_changed


var config: ConfigFile = ConfigFile.new()



func set_setting(setting: String, val: Variant) -> void:
	config.set_value("Main", setting, val)

	printt("setting", setting, val)

	setting_changed.emit()


func get_setting(setting: String, default: Variant) -> Variant:
	return config.get_value("Main", setting, default)
