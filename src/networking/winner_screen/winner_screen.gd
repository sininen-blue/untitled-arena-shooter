class_name WinnerScreen
extends Control


signal finished()


@export var winner_name: String = ""


@onready var player_name: Label = $PlayerName
@onready var winner_label: Label = $WinnerLabel


func _ready() -> void:
	self.visible = false


@rpc("authority", "call_local", "reliable")
func start(new_winner_name: String) -> void:
	self.visible = true

	winner_name = new_winner_name
	player_name.text = winner_name


	await _tween_labels().finished

	self.visible = false
	finished.emit()


func _tween_labels() -> Tween:
	winner_label.offset_transform_enabled = true
	player_name.offset_transform_enabled = true
	player_name.text = winner_name

	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)

	tween.tween_property(winner_label, "visible", true, 0)
	tween.tween_property(player_name, "visible", true, 0)

	tween.chain().tween_property(winner_label, "offset_transform_scale", Vector2.ZERO, 0)
	tween.tween_property(winner_label, "offset_transform_rotation", 0.0, 0)
	tween.tween_property(player_name, "offset_transform_scale", Vector2.ZERO, 0)
	tween.tween_property(player_name, "offset_transform_rotation", 0.0, 0)

	tween.chain().tween_property(winner_label, "offset_transform_scale", Vector2(2, 2), 2)
	tween.tween_property(winner_label, "offset_transform_rotation", deg_to_rad(360), 2)
	tween.tween_property(player_name, "offset_transform_scale", Vector2(1.5, 1.5), 2)
	tween.tween_property(player_name, "offset_transform_rotation", deg_to_rad(-360), 2)

	tween.chain().tween_property(winner_label, "offset_transform_scale", Vector2.ZERO, 1)
	tween.tween_property(winner_label, "offset_transform_rotation", 0.0, 1)
	tween.tween_property(player_name, "offset_transform_scale", Vector2.ZERO, 1)
	tween.tween_property(player_name, "offset_transform_rotation", deg_to_rad(360), 1)

	tween.chain().tween_property(winner_label, "visible", false, 0)
	tween.tween_property(player_name, "visible", false, 0)
	return tween
