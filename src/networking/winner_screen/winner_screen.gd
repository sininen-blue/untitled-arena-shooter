class_name WinnerScreen
extends Label


signal finished()


@rpc("any_peer", "call_local", "reliable")
func start() -> void:
	self.offset_transform_enabled = true
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "visible", true, 0.1)
	tween.tween_property(self, "offset_transform_scale", Vector2(2, 2), 2)
	tween.parallel().tween_property(self, "offset_transform_rotation", deg_to_rad(360), 2)
	
	tween.tween_property(self, "offset_transform_scale", Vector2(0, 0), 1)
	tween.parallel().tween_property(self, "offset_transform_rotation", deg_to_rad(0), 1)
	tween.tween_property(self, "visible", false, 0.1)
	
	await tween.finished
	finished.emit()
