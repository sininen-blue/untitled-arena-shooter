class_name ParryEffect
extends MeshInstance3D

@export var default_duration: float = 2.0

var mat: ShaderMaterial

func start(duration: float = default_duration) -> void:
	mat = get_active_material(0).duplicate()
	set_surface_override_material(0, mat)
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(self, "visible", true, 0)
	tween.tween_method(set_shader_timescale, 0.0, 1.0, duration)
	tween.tween_property(self, "visible", false, 0)


func set_shader_timescale(value: float) -> void:
	mat.set_shader_parameter("wave_age", value)
