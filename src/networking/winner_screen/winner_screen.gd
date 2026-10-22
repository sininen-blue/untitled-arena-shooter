class_name WinnerScreen
extends Label


signal finished()


@export var winner_name: String = ""


@onready var player_name: Label = $PlayerName


func _ready() -> void:
	self.visible = false


@rpc("authority", "call_local", "reliable")
func start(new_winner_name: String) -> void:
	winner_name = new_winner_name
	player_name.text = winner_name


	var win_tween := tween_win()
	var name_tween := tween_name()

	await win_tween.finished
	await name_tween.finished

	finished.emit()


func tween_win() -> Tween:
	self.offset_transform_enabled = true

	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "visible", true, 0)
	tween.tween_property(self, "offset_transform_scale", Vector2(0, 0), 0)
	
	tween.tween_property(self, "offset_transform_scale", Vector2(2, 2), 2)
	tween.parallel().tween_property(self, "offset_transform_rotation", deg_to_rad(360), 2)
	
	tween.tween_property(self, "offset_transform_scale", Vector2(0, 0), 1)
	tween.parallel().tween_property(self, "offset_transform_rotation", deg_to_rad(0), 1)
	tween.tween_property(self, "visible", false, 0)

	return tween



func tween_name() -> Tween:
	player_name.text = winner_name
	player_name.offset_transform_enabled = true

	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(player_name, "visible", true, 0)
	tween.tween_property(player_name, "offset_transform_scale", Vector2(0, 0), 0)
	tween.parallel().tween_property(player_name, "offset_transform_rotation", deg_to_rad(0), 2)
	
	tween.tween_property(player_name, "offset_transform_scale", Vector2(1.5, 1.5), 2)
	tween.parallel().tween_property(player_name, "offset_transform_rotation", deg_to_rad(-45), 2)
	
	tween.tween_property(player_name, "offset_transform_scale", Vector2(0, 0), 1)
	tween.parallel().tween_property(player_name, "offset_transform_rotation", deg_to_rad(45), 1)
	
	tween.tween_property(player_name, "visible", false, 0)
	return tween
