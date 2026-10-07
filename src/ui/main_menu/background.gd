extends ColorRect

func _process(_delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	self.material.set_shader_parameter("mouse_pos", mouse / vp_size)
