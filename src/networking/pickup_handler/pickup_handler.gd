class_name PickupHandler
extends Node


@export var main: Node


func request_equip(target_name: String, weapon_path: String, ammo: int) -> void:
	_equip.rpc_id(1, target_name, weapon_path, ammo)


@rpc("any_peer", "reliable")
func _equip(target_name: String, weapon_path: String, ammo: int) -> void:
	if not multiplayer.is_server():
		return
	var sender := Utils.sender_id(self)
	if str(sender) != target_name:
		return
	give_weapon.rpc(target_name, weapon_path, ammo)


@rpc("authority", "call_local", "reliable")
func give_weapon(target_name: String, weapon_path: String, ammo: int) -> void:
	var target: Player = Utils.find_player(target_name, main)
	if target == null:
		return

	_free_current(target)

	var packed: Resource = load(weapon_path) if weapon_path.begins_with("res://src/entities/weapons/") else null
	if packed == null or not packed is PackedScene:
		return

	var weapon_instance: HitscanWeapon = packed.instantiate()
	if weapon_instance == null or not weapon_instance is HitscanWeapon:
		if is_instance_valid(weapon_instance):
			weapon_instance.queue_free()
		return

	weapon_instance.ammo = ammo
	weapon_instance.held = true
	weapon_instance.player = target
	target.hand_marker.add_child(weapon_instance)
	target.current_weapon = weapon_instance
	
	target.has_weapon = true
	if weapon_instance.is_handgun:
		target.has_handgun = true
	if weapon_instance.is_longgun:
		target.has_longgun = true


func request_drop(ammo: int, spawn_loc: Vector3, throw_dir: Vector3, throw_rot: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	_request_drop.rpc_id(1, ammo, spawn_loc, throw_dir, throw_rot)


@rpc("any_peer", "call_local", "reliable")
func _request_drop(ammo: int, spawn_loc: Vector3, throw_dir: Vector3, throw_rot: float) -> void:
	if not multiplayer.is_server() or not main.is_combat_live():
		return

	var id := Utils.sender_id(self)
	if main.damage_handler.is_dead(id):
		return

	var player := Utils.find_player(str(id), main)
	if player == null or player.current_weapon == null:
		return

	main.dropped_spawner.spawn_dropped_weapon({
		"file_path": player.current_weapon.scene_file_path,
		"ammo": int(player.current_weapon.ammo),
	}, spawn_loc, throw_dir, throw_rot)
	clear_player(player.name)


func request_claim(pickup_path: NodePath) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	_request_claim.rpc_id(1, pickup_path)


@rpc("any_peer", "call_local", "reliable")
func _request_claim(pickup_path: NodePath) -> void:
	if not multiplayer.is_server() or not main.is_combat_live():
		return

	var id := Utils.sender_id(self)
	if main.damage_handler.is_dead(id):
		return

	var pickup := get_node_or_null(pickup_path)
	if pickup == null or not pickup.has_method("can_claim"):
		return

	if not pickup.can_claim():
		return
	pickup.claim()

	var player := Utils.find_player(str(id), main)
	if player == null:
		return

	var default_weapon: HitscanWeapon = pickup.weapon.instantiate()
	var ammo := int(default_weapon.ammo)
	default_weapon.queue_free()

	give_weapon.rpc(player.name, pickup.weapon.resource_path, ammo)


func request_dropped_pickup(weapon_name: String) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	_request_dropped_pickup.rpc_id(1, weapon_name)


@rpc("any_peer", "call_local", "reliable")
func _request_dropped_pickup(weapon_name: String) -> void:
	if not multiplayer.is_server() or not main.is_combat_live():
		return

	var id := Utils.sender_id(self)
	if main.damage_handler.is_dead(id):
		return

	var dropped = main.dropped_spawner.get_node(main.dropped_spawner.spawn_path).get_node_or_null(weapon_name)
	if dropped == null:
		return

	var player := Utils.find_player(str(id), main)
	if player == null:
		return

	give_weapon.rpc(player.name, dropped.weapon_file_path, int(dropped.weapon_ammo))
	main.dropped_spawner.despawn_dropped_weapon(weapon_name)


func request_remove_weapon(requester: Player) -> void:
	_remove.rpc_id(1, requester.name)


@rpc("any_peer", "reliable")
func _remove(target_name: String) -> void:
	if not multiplayer.is_server():
		return
	remove_weapon.rpc(target_name)


@rpc("authority", "call_local", "reliable")
func remove_weapon(target_name: String) -> void:
	var target: Player = Utils.find_player(target_name, main)
	if target == null:
		return
	_free_current(target)


func clear_player(target_name: String) -> void:
	if not multiplayer.is_server():
		return
	remove_weapon.rpc(target_name)


func _free_current(target: Player) -> void:
	if target.current_weapon == null:
		return
	var old := target.current_weapon
	target.current_weapon = null
	
	target.has_weapon = false
	target.has_handgun = false
	target.has_longgun = false
	old.queue_free()
