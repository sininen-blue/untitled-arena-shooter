class_name DroppedSpawner
extends MultiplayerSpawner


@export var weapon_throw_force: float = 8.0
@export var dropped_weapon_scene: PackedScene


@onready var dropped_weapons: Node3D = $"../DroppedWeapons"


func request_spawn(weapon: HitscanWeapon, spawn_loc: Vector3, throw_dir: Vector3, throw_rot: float) -> void:
	var weapon_data: Dictionary = _serialize(weapon)
	print(weapon_data)

	spawn_dropped_weapon.rpc_id(1, weapon_data, spawn_loc, throw_dir, throw_rot)


@rpc("any_peer", "call_local", "reliable")
func spawn_dropped_weapon(weapon_data: Dictionary, spawn_loc: Vector3, throw_dir: Vector3, throw_rot: float) -> void:
	if not multiplayer.is_server():
		return
	
	var dropped_weapon_instance: DroppedWeapon = dropped_weapon_scene.instantiate()
	
	var weapon: HitscanWeapon = load(weapon_data.get("file_path")).instantiate()
	weapon.ammo = weapon_data.get("ammo")
	print(weapon)
	dropped_weapon_instance.weapon_instance = weapon

	dropped_weapons.add_child(dropped_weapon_instance, true)

	dropped_weapon_instance.global_position = spawn_loc

	dropped_weapon_instance.rotation.y = throw_rot

	await get_tree().physics_frame
	dropped_weapon_instance.apply_central_impulse(throw_dir * weapon_throw_force)
	


func _serialize(weapon: HitscanWeapon) -> Dictionary:
	return {
		"file_path": weapon.scene_file_path,
		"ammo": weapon.ammo,
	}
