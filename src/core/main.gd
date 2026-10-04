extends Node


var current_level: BaseLevel

@onready var dropped_spawner: DroppedSpawner = $DroppedSpawner
@onready var player_spawner: PlayerSpawner = %PlayerSpawner


func _ready() -> void:
	for child: Node in get_children():
		if child is BaseLevel:
			current_level = child
			break
	
	player_spawner.start()
	
	if multiplayer.is_server() != true:
		return

	await player_spawner.all_players_spawned
	await get_tree().create_timer(.5).timeout # TODO: fuckass grace, replace at some point
	place_players()
	await get_tree().create_timer(2).timeout # TODO: replace with timer
	release_players()


func switch_map() -> void:
	pass


func place_players() -> void:
	var players: Array[Player] = []
	for child: Node in get_children():
		if child is Player:
			players.append(child)
	
	var possible_locs: Array[Vector3] = current_level.spawn_locations.duplicate()
	
	for player: Player in players:
		var pos: Vector3 = possible_locs.pick_random()
		possible_locs.erase(pos)
		_set_player_position.rpc_id(player.get_multiplayer_authority(), player.name, pos)


@rpc("authority", "call_local", "reliable")
func _set_player_position(player_name: String, pos: Vector3) -> void:
	var player: Player = _find_player(player_name)
	if player:
		player.global_position = pos
		player.locked = true


func release_players() -> void:
	for child: Node in get_children():
		if child is Player:
			child.locked = false


func request_weapon(requester: Player, weapon_instance: HitscanWeapon) -> void:
	var weapon_path: String = weapon_instance.scene_file_path
	var ammo: int = weapon_instance.ammo
	
	give_weapon.rpc(requester.name, weapon_path, ammo)


@rpc("any_peer", "call_local", "reliable")
func give_weapon(target_name: String, weapon_path: String, ammo: int) -> void:
	var weapon_instance: HitscanWeapon = load(weapon_path).instantiate()
	weapon_instance.ammo = ammo
	
	var target: Player = _find_player(target_name)
	
	target.hand_marker.add_child(weapon_instance)
	target.current_weapon = weapon_instance


func request_remove_weapon(requester: Player) -> void:
	remove_weapon.rpc(requester.name)


@rpc("any_peer", "call_local", "reliable")
func remove_weapon(target_name: String) -> void:
	var target: Player = _find_player(target_name)
	
	target.hand_marker.remove_child(target.current_weapon)


func _find_player(player_name: String) -> Player:
	for child: Node in get_children():
		if child is Player and child.name == player_name:
			return child
	return null
