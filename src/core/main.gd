extends Node


var current_level: BaseLevel


@onready var weapon_pickup_sync: WeaponPickupSync = %WeaponPickupSync
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
	var player: Player = Utils.find_player(player_name, self)
	if player:
		player.global_position = pos
		player.locked = true


func release_players() -> void:
	for child: Node in get_children():
		if child is Player:
			child.locked = false
