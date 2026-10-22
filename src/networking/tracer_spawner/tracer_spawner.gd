class_name TracerSpawner
extends MultiplayerSpawner

@export var tracer_scene: PackedScene


func _ready() -> void:
	self.spawn_function = _spawn_function


func request_spawn(start: Vector3, end: Vector3) -> void:
	_spawn_tracer.rpc_id(1, start, end)


@rpc("any_peer", "call_local", "reliable")
func _spawn_tracer(start: Vector3, end: Vector3) -> void:
	if not multiplayer.is_server():
		return

	var data: Dictionary[String, Vector3] = {
		"start": start,
		"end": end,
	}
	spawn(data)


func request_despawn(tracer: BulletTracer) -> void:
	_despawn_tracer.rpc_id(1, tracer.name)


@rpc("any_peer", "call_local", "reliable")
func _despawn_tracer(tracer_name: String) -> void:
	if not multiplayer.is_server():
		return

	var tracer := get_node(spawn_path).get_node_or_null(tracer_name)
	if tracer:
		tracer.queue_free()


func _spawn_function(data: Dictionary) -> Node3D:
	var tracer_instance: BulletTracer = tracer_scene.instantiate()

	tracer_instance.spawner = self
	tracer_instance.pending_start = data.get("start")
	tracer_instance.pending_end = data.get("end")

	return tracer_instance
