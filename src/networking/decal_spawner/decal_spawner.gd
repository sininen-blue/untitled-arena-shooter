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


func request_despawn(decal: HitDecal) -> void:
	_despawn_decal.rpc_id(1, decal.name)


@rpc("any_peer", "call_local", "reliable")
func _despawn_decal(decal_name: String) -> void:
	if not multiplayer.is_server():
		return

	var decal: Node = get_node(spawn_path).get_node_or_null(decal_name)
	if decal:
		decal.queue_free()


func _spawn_function(data: Dictionary) -> HitDecal:
	var hit_decal_instance: HitDecal = hit_decal_scene.instantiate()

	hit_decal_instance.spawner = self
	hit_decal_instance.pending_position = data.get("location")
	hit_decal_instance.pending_normal = data.get("normal")

	return hit_decal_instance
