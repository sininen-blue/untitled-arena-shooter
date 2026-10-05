extends Node


var current_level: BaseLevel


@onready var weapon_pickup_sync: WeaponPickupSync = %WeaponPickupSync
@onready var dropped_spawner: DroppedSpawner = $DroppedSpawner
@onready var decal_spawner: DecalSpawner = %DecalSpawner
@onready var player_spawner: PlayerSpawner = %PlayerSpawner
@onready var score_handler: ScoreHandler = $ScoreHandler
@onready var winner_screen: WinnerScreen = %WinnerScreen


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
	connect_signals()
	ready_scores()
	await get_tree().create_timer(2).timeout # TODO: replace with timer
	release_players.rpc()


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


func reset_player_healths() -> void:
	# TODO: reconfigure this to be a singular call
	var players: Array[Player] = []
	for child: Node in get_children():
		if child is Player:
			players.append(child)
	
	for player: Player in players:
		_reset_player_health.rpc_id(player.get_multiplayer_authority(), player.name)


func reset_player_visibilities() -> void:
	var players: Array[Player] = []
	for child: Node in get_children():
		if child is Player:
			players.append(child)
	
	for player: Player in players:
		_reset_player_visibility.rpc_id(player.get_multiplayer_authority(), player.name)


func reset_player_weapons() -> void:
	var players: Array[Player] = []
	for child: Node in get_children():
		if child is Player:
			players.append(child)
	
	for player: Player in players:
		_reset_player_weapon.rpc_id(player.get_multiplayer_authority(), player.name)


func connect_signals() -> void:
	var players: Array[Player] = []
	for child: Node in get_children():
		if child is Player:
			players.append(child)
	
	for player: Player in players:
		player.killed.connect(_on_player_killed)


func ready_scores() -> void:
	var players: Array[Player] = []
	for child: Node in get_children():
		if child is Player:
			players.append(child)
	
	for player: Player in players:
		score_handler.add_score(int(player.name), 0)


@rpc("authority", "call_local", "reliable")
func _set_player_position(player_name: String, pos: Vector3) -> void:
	var player: Player = Utils.find_player(player_name, self)
	if player:
		player.locked = true
		player.global_position = pos


@rpc("authority", "call_local", "reliable")
func _reset_player_health(player_name: String) -> void:
	var player: Player = Utils.find_player(player_name, self)
	if player:
		player.health = player.max_health


@rpc("authority", "call_local", "reliable")
func _reset_player_visibility(player_name: String) -> void:
	var player: Player = Utils.find_player(player_name, self)
	if player:
		player.visible = true


@rpc("authority", "call_local", "reliable")
func _reset_player_weapon(player_name: String) -> void:
	var player: Player = Utils.find_player(player_name, self)
	if player and player.current_weapon != null:
		player.remove_weapon()


@rpc("any_peer", "call_local", "reliable")
func release_players() -> void:
	for child: Node in get_children():
		if child is Player:
			child.locked = false


func _on_player_killed(by_id: int, who: Player) -> void:
	if multiplayer.is_server() == false:
		return
	
	score_handler.add_score(by_id, 1)
	show_winner()


func show_winner() -> void:
	winner_screen.start()


func _on_winner_screen_finished() -> void:
	if multiplayer.is_server() != true:
		return
	
	place_players()
	reset_player_healths()
	reset_player_visibilities()
	reset_player_weapons()
	dropped_spawner.clear_dropped_weapons()
	
	await get_tree().create_timer(2).timeout
	release_players.rpc()
