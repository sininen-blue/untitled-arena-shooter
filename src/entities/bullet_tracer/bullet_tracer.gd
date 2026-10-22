class_name BulletTracer
extends MeshInstance3D

@export var tracer_fade: ShaderMaterial
@export var lifetime: float = 0.3

var spawner: TracerSpawner
var pending_start: Vector3
var pending_end: Vector3


func _ready() -> void:
	var distance = pending_start.distance_to(pending_end)
	(mesh as CapsuleMesh).radius = 0.01
	(mesh as CapsuleMesh).height = distance
	
	global_position = (pending_start + pending_end) / 2.0
	var dir = (pending_end - pending_start).normalized()
	if abs(dir.dot(Vector3.UP)) > 0.999:
		look_at(pending_end, Vector3.FORWARD)
	else:
		look_at(pending_end, Vector3.UP)
		
	self.rotate_object_local(Vector3.RIGHT, PI / 2.0)
	
	self.material_override = tracer_fade.duplicate()
	
	var tween = create_tween()
	tween.tween_method(
		func(v: float): self.material_override.set_shader_parameter("fade_progress", v),
		1.0, 0.0, lifetime
	)
	tween.tween_callback(_request_despawn)


func _request_despawn() -> void:
	if not is_inside_tree():
		return
	if multiplayer.multiplayer_peer != null and not multiplayer.is_server():
		return
	if spawner:
		spawner.request_despawn(self)
	else:
		queue_free()
