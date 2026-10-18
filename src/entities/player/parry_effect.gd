class_name ParryEffect
extends MeshInstance3D

var mat: ShaderMaterial

func start() -> void:
	mat = get_active_material(0)
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(self, "visible", true, 0)
	tween.tween_method(set_shader_timescale, 0.0, 1.0, 1.2)
	tween.tween_property(self, "visible", false, 0)


func set_shader_timescale(value: float) -> void:
	mat.set_shader_parameter("wave_age", value)
