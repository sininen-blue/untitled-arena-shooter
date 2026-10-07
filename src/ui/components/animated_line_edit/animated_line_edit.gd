class_name AnimatedLineEdit
extends LineEdit


func _ready() -> void:
	self.offset_transform_enabled = true
	self.text_changed.connect(_on_text_changed)


func _on_text_changed(_new_text: String) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_rotation", 0.04, 0.1)
	tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1.05, 1.05), 0.1)
	
	tween.tween_property(self, "offset_transform_rotation", 0, 0.1)
	tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.1)
