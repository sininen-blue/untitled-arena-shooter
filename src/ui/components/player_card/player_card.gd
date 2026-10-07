class_name PlayerCard
extends Panel


@export var player_name: String = "":
	set = _set_player_name


@onready var label: Label = $Label


func _ready() -> void:
	label.text = player_name
	
	self.offset_transform_enabled = true
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_rotation", randf_range(-0.2, 0.2), 0.3)
	tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1.4, 1.4), 0.3)
	tween.tween_property(self, "offset_transform_rotation", 0, 0.2)
	tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.2)


func _set_player_name(new_text: String) -> void:
	player_name = new_text
	
	if label:
		label.text = player_name
