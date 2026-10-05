class_name DroppedSpawner
extends MultiplayerSpawner


@export var weapon_throw_force: float = 8.0
@export var dropped_weapon_scene: PackedScene


@onready var dropped_weapons: Node3D = $"../DroppedWeapons"


func _ready() -> void:
	spawn_function = _spawn_function


func clear_dropped_weapons() -> void:
	for child in dropped_weapons.get_children():
		if child is DroppedWeapon:
			request_despawn(child)



func request_spawn(weapon: HitscanWeapon, spawn_loc: Vector3, throw_dir: Vector3, throw_rot: float) -> void:
	var weapon_data: Dictionary = _serialize(weapon)

	spawn_dropped_weapon.rpc_id(1, weapon_data, spawn_loc, throw_dir, throw_rot)


@rpc("any_peer", "call_local", "reliable")
func spawn_dropped_weapon(weapon_data: Dictionary, spawn_loc: Vector3, throw_dir: Vector3, throw_rot: float) -> void:
	if not multiplayer.is_server():
		return
	
	spawn({
		"file_path": weapon_data.get("file_path"),
		"ammo": weapon_data.get("ammo"),
		"spawn_loc": spawn_loc,
		"throw_dir": throw_dir,
		"throw_rot": throw_rot,
	})


func request_despawn(weapon: DroppedWeapon) -> void:
	despawn_dropped_weapon.rpc_id(1, weapon.name)


@rpc("any_peer", "call_local", "reliable")
func despawn_dropped_weapon(weapon_name: String) -> void:
	if not multiplayer.is_server():
		return

	var weapon: Node = dropped_weapons.get_node_or_null(weapon_name)
	if weapon:
		weapon.queue_free()



func _serialize(weapon: HitscanWeapon) -> Dictionary:
	return {
		"file_path": weapon.scene_file_path,
		"ammo": weapon.ammo,
	}


func _spawn_function(data: Dictionary) -> Node:
	var dropped_weapon_instance: DroppedWeapon = dropped_weapon_scene.instantiate()

	dropped_weapon_instance.weapon_file_path = data.get("file_path")
	dropped_weapon_instance.weapon_ammo = data.get("ammo")
	
	dropped_weapon_instance.spawner = self
	dropped_weapon_instance.pending_impulse = data.get("throw_dir") * weapon_throw_force
	dropped_weapon_instance.pending_position = data.get("spawn_loc")
	dropped_weapon_instance.rotation.y = data.get("throw_rot")

	return dropped_weapon_instance
