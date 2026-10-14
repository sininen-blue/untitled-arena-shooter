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


func _spawn_function(data: Dictionary) -> Node3D:
	var tracer_instance: Node3D = tracer_scene.instantiate()

	tracer_instance.pending_start = data.get("start")
	tracer_instance.pending_end = data.get("end")

	return tracer_instance
