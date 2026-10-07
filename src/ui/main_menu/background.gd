extends ColorRect

var current: Vector2

func _process(delta: float) -> void:
	var mouse = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	
	current = Utils.exp_decay(current, mouse/vp_size, 2.0, delta)
	
	self.material.set_shader_parameter("mouse_pos", current)
