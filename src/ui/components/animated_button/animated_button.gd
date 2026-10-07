class_name AnimatedButton
extends Button


func _ready() -> void:
	self.offset_transform_enabled = true
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	self.offset_transform_pivot = Vector2(self.size.x/2, self.size.y/2)
	
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_scale", Vector2(1.2, 1.2), 0.2)


func _on_mouse_exited() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.2)
