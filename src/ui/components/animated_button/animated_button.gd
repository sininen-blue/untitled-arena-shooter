class_name AnimatedButton
extends Button


func _ready() -> void:
	self.offset_transform_enabled = true
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	self.button_down.connect(_on_button_down)
	self.button_up.connect(_on_button_up)


func _on_mouse_entered() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_rotation", 0.1, 0.2)
	tween.tween_property(self, "offset_transform_scale", Vector2(1.2, 1.2), 0.2)


func _on_mouse_exited() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_rotation", 0, 0.2)
	tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.2)


func _on_button_down() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_rotation", 0, 0.2)
	tween.tween_property(self, "offset_transform_scale", Vector2(0.8, 0.8), 0.2)


func _on_button_up() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_rotation", -0.1, 0.2)
	tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1.1, 1.1), 0.2)
	
	tween.tween_property(self, "offset_transform_rotation", 0, 0.2)
	tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.2)
