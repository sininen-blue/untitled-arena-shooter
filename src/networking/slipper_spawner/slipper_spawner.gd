class_name SlipperSpanwner
extends MultiplayerSpawner


@export var slipper_scene: PackedScene


@onready var slippers: Node3D = %Slippers


func _ready() -> void:
	spawn_function = _spawn_function


func request_spawn(sender: Player, loc: Vector3, throw_vector: Vector3) -> void:
	_spawn_slipper.rpc_id(1, int(sender.name), loc, throw_vector)


@rpc("any_peer", "call_local", "reliable")
func _spawn_slipper(sender_id: int, loc: Vector3, throw_vector: Vector3) -> void:
	if not multiplayer.is_server():
		pass
	
	var data: Dictionary = {
		"sender_id": sender_id,
		"spawn_location": loc,
		"throw_vector": throw_vector,
	}
	self.spawn(data)


func request_despawn(slipper: Slipper) -> void:
	despawn_slipper.rpc_id(1, slipper.name)


@rpc("any_peer", "call_local", "reliable")
func despawn_slipper(slipper_name: String) -> void:
	if not multiplayer.is_server():
		return

	var slipper: Node = slippers.get_node_or_null(slipper_name)
	if slipper:
		slipper.queue_free()


func _spawn_function(data: Dictionary) -> Slipper:
	var throw_force: Vector3 = data.get("throw_vector")
	var spawn_location: Vector3 = data.get("spawn_location")
	var sender_id: int = data.get("sender_id")
	
	var slipper_instance: Slipper = slipper_scene.instantiate()
	slipper_instance.spawner = self
	slipper_instance.sender = sender_id
	slipper_instance.pending_position = spawn_location
	slipper_instance.pending_impulse = throw_force
	
	return slipper_instance
