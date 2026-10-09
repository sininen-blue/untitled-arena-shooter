class_name DecalSpawner
extends MultiplayerSpawner

@export var hit_decal_scene: PackedScene


func _ready() -> void:
	self.spawn_function = _spawn_function


func request_spawn(loc: Vector3, normal: Vector3) -> void:
	_spawn_decal.rpc_id(1, loc, normal)


@rpc("any_peer", "call_local", "reliable")
func _spawn_decal(location: Vector3, normal: Vector3) -> void:
	if not multiplayer.is_server():
		return
	
	var data: Dictionary[String, Vector3] = {
		"location": location,
		"normal": normal,
	}
	spawn(data)


func _spawn_function(data: Dictionary) -> Decal:
	var hit_decal_instance: Decal = hit_decal_scene.instantiate()

	hit_decal_instance.pending_position = data.get("location")
	hit_decal_instance.pending_normal = data.get("normal")

	return hit_decal_instance
