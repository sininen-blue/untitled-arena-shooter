class_name DecalSpawner
extends MultiplayerSpawner

@export var hit_decal_scene: PackedScene


func _ready() -> void:
	self.spawn_function = _spawn_function


func request_spawn(loc: Vector3) -> void:
	_spawn_decal.rpc_id(1, loc)


@rpc("any_peer", "call_local", "reliable")
func _spawn_decal(location: Vector3) -> void:
	if not multiplayer.is_server():
		return
	
	spawn(location)


func _spawn_function(location: Vector3) -> Decal:
	var hit_decal_instance: Decal = hit_decal_scene.instantiate()
	hit_decal_instance.pending_position = location

	return hit_decal_instance
