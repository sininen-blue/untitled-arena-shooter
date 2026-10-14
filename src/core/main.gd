extends Node


signal clients_ready


@export var current_level: BaseLevel


var ready_clients: Array[int]
var players: Array
var players_killed: Array[int]


@onready var weapon_pickup_sync: WeaponPickupSync = %WeaponPickupSync
@onready var dropped_spawner: DroppedSpawner = $DroppedSpawner
@onready var slipper_spawner: SlipperSpanwner = %SlipperSpawner
@onready var decal_spawner: DecalSpawner = %DecalSpawner
@onready var player_spawner: PlayerSpawner = %PlayerSpawner
@onready var score_handler: ScoreHandler = $ScoreHandler
@onready var winner_screen: WinnerScreen = %WinnerScreen
@onready var countdown: Countdown = %Countdown
@onready var score_panel: ScorePanel = %ScorePanel


func _ready() -> void:
	# await get_tree().create_timer(2).timeout
	
	if multiplayer.is_server():
		self.clients_ready.connect(_on_clients_ready)
		_notify_ready()
	else:
		_notify_ready.rpc_id(1)


@rpc("any_peer", "reliable")
func _notify_ready() -> void:
	var id: int = multiplayer.get_remote_sender_id()
	if id == 0:
		id = multiplayer.get_unique_id()
	
	ready_clients.append(id)
	_check_all_ready()


func _check_all_ready() -> void:
	if ready_clients.size() == NetworkManager.players.size():
		clients_ready.emit()


func _on_clients_ready() -> void:
	if not multiplayer.is_server():
		return
	await get_tree().process_frame
	
	player_spawner.start()
	await player_spawner.all_players_spawned
	await get_tree().create_timer(0.2).timeout # replace later
	
	players = self.get_children().filter(func(c): return c is Player)
	
	place_players()
	connect_signals()
	ready_scores()
	countdown.start.rpc(3)
	await countdown.finished
	release_players.rpc()


func place_players() -> void:
	var possible_locs: Array[Vector3] = current_level.spawn_locations.duplicate()
	for player: Player in players:
		var pos: Vector3 = possible_locs.pick_random()
		possible_locs.erase(pos)
		_set_player_position.rpc_id(player.get_multiplayer_authority(), player.name, pos)


func reset_player_healths() -> void:
	for player: Player in players:
		_reset_player_health.rpc_id(player.get_multiplayer_authority(), player.name)


func reset_player_visibilities() -> void:
	for player: Player in players:
		_reset_player_visibility.rpc_id(player.get_multiplayer_authority(), player.name)


func reset_player_weapons() -> void:
	for player: Player in players:
		_reset_player_weapon.rpc_id(player.get_multiplayer_authority(), player.name)


func connect_signals() -> void:
	for player: Player in players:
		player.killed.connect(_on_player_killed)


func ready_scores() -> void:
	for player: Player in players:
		score_handler.add_score(int(player.name), 0)


func reset_scores() -> void:
	for player_id: int in score_handler.scores:
		score_handler.scores[player_id] = 0


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
		player.health_bar.current_health = player.health


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


func _on_player_killed(_by_id: int, who: Player) -> void:
	if multiplayer.is_server() == false:
		return

	players_killed.append(int(who.name))

	if players_killed.size() == NetworkManager.players.size()-1:
		for player_id in NetworkManager.players:
			if player_id not in players_killed:
				score_handler.add_score(player_id, 1)
				break

		winner_screen.start.rpc()


func _on_winner_screen_finished() -> void:
	if multiplayer.is_server() != true:
		return
	
	score_panel.start.rpc()
	await score_panel.finished

	place_players()
	reset_player_healths()
	reset_player_visibilities()
	reset_player_weapons()
	reset_scores()
	players_killed.clear()
	dropped_spawner.clear_dropped_weapons()
	
	countdown.start.rpc(3)
	await countdown.finished
	release_players.rpc()
