extends Node


@export var current_level: BaseLevel


enum Phase { HANDSHAKE, COUNTDOWN, LIVE, ENDING, RESET }
var phase: Phase = Phase.HANDSHAKE

var players: Array = []
var players_killed: Array[int] = []

var level_ready: Dictionary[int, bool] = {}
var spawn_ready: Dictionary[int, bool] = {}

var level_acked: bool = false
var spawn_acked: bool = false

var spawn_started: bool = false
var round_started: bool = false

var finishing_round: bool = false


@onready var pickup_handler: PickupHandler = $PickupHandler
@onready var dropped_spawner: DroppedSpawner = $DroppedSpawner
@onready var slipper_spawner: SlipperSpanwner = %SlipperSpawner
@onready var tracer_spawner: TracerSpawner = %TracerSpawner
@onready var decal_spawner: DecalSpawner = %DecalSpawner
@onready var jump_particle_spawner: JumpParticleSpawner = $JumpParticleSpawner
@onready var land_particle_spawner: LandParticleSpawner = $LandParticleSpawner
@onready var damage_number_spawner: DamageNumberSpawner = $DamageNumberSpawner
@onready var damage_handler: DamageHandler = $DamageHandler
@onready var parry_handler: ParryHandler = $ParryHandler
@onready var player_spawner: PlayerSpawner = %PlayerSpawner
@onready var score_handler: ScoreHandler = $ScoreHandler
@onready var winner_screen: WinnerScreen = %WinnerScreen
@onready var countdown: Countdown = %Countdown
@onready var score_panel: ScorePanel = %ScorePanel


func _ready() -> void:
	damage_handler.player_died.connect(_record_death)

	if multiplayer.multiplayer_peer == null:
		return

	_retry_level_ready()

	if multiplayer.is_server():
		get_tree().create_timer(NetworkManager.ACK_TIMEOUT).timeout.connect(_on_level_timeout)


func is_combat_live() -> bool:
	return phase == Phase.LIVE


func notify_player_spawned() -> void:
	_retry_spawn_ready()


func _retry_level_ready() -> void:
	while is_inside_tree() and not level_acked:
		if multiplayer.multiplayer_peer == null:
			return
		_report_level_ready.rpc_id(1)
		await get_tree().create_timer(0.25).timeout


func _retry_spawn_ready() -> void:
	while is_inside_tree() and not spawn_acked:
		if multiplayer.multiplayer_peer == null:
			return
		_report_spawn_ready.rpc_id(1)
		await get_tree().create_timer(0.25).timeout


func _on_level_timeout() -> void:
	if spawn_started or not is_inside_tree():
		return
	NetworkManager.end_session()


func _on_spawn_timeout() -> void:
	if round_started or not is_inside_tree():
		return
	NetworkManager.end_session()


@rpc("any_peer", "call_local", "reliable")
func _report_level_ready() -> void:
	if not multiplayer.is_server():
		return

	var id := Utils.sender_id(self)
	level_ready[id] = true

	if id == multiplayer.get_unique_id():
		level_acked = true
	else:
		_ack_level.rpc_id(id)

	if not spawn_started and level_ready.size() >= NetworkManager.players.size():
		_begin_spawn()


@rpc("authority", "reliable")
func _ack_level() -> void:
	level_acked = true


@rpc("any_peer", "call_local", "reliable")
func _report_spawn_ready() -> void:
	if not multiplayer.is_server():
		return

	var id := Utils.sender_id(self)
	spawn_ready[id] = true

	if id == multiplayer.get_unique_id():
		spawn_acked = true
	else:
		_ack_spawn.rpc_id(id)

	if not round_started and spawn_ready.size() >= NetworkManager.players.size():
		_start_first_round()


@rpc("authority", "reliable")
func _ack_spawn() -> void:
	spawn_acked = true


func _begin_spawn() -> void:
	if spawn_started:
		return
	spawn_started = true

	player_spawner.start()
	get_tree().create_timer(NetworkManager.ACK_TIMEOUT).timeout.connect(_on_spawn_timeout)


func _start_first_round() -> void:
	if round_started or not multiplayer.is_server():
		return
	round_started = true

	await get_tree().process_frame

	if not is_inside_tree():
		return
	players = Utils.player_children(self)
	damage_handler.reset_tables(players)

	for player: Player in players:
		score_handler.add_score(int(player.name), 0)

	_begin_countdown()



func _begin_countdown() -> void:
	phase = Phase.COUNTDOWN
	_set_locked.rpc(true)

	place_players()
	countdown.start.rpc(3)
	await countdown.finished

	if not is_inside_tree() or phase == Phase.ENDING:
		return

	phase = Phase.LIVE

	_set_locked.rpc(false)


func place_players() -> void:
	var possible_locs: Array[Vector3] = current_level.spawn_locations.duplicate()
	for player: Player in players:
		if player.is_dead:
			continue
		var pos: Vector3 = possible_locs.pick_random()
		possible_locs.erase(pos)
		_set_player_position.rpc_id(player.get_multiplayer_authority(), player.name, pos)



@rpc("authority", "call_local", "reliable")
func _set_player_position(player_name: String, pos: Vector3) -> void:
	var player: Player = Utils.find_player(player_name, self)
	if player:
		player.locked = true
		player.global_position = pos


@rpc("authority", "call_local", "reliable")
func _set_locked(is_locked: bool) -> void:
	for child: Node in get_children():
		if child is Player and not child.is_dead:
			child.locked = is_locked


func _record_death(id: int) -> void:
	if id in players_killed or phase != Phase.LIVE:
		return

	players_killed.append(id)
	if players_killed.size() != NetworkManager.players.size() - 1:
		return

	phase = Phase.ENDING
	_set_locked.rpc(true)

	for player_id: int in NetworkManager.players:
		if player_id not in players_killed:
			score_handler.add_score(player_id, 1)
			break

	winner_screen.start.rpc()


func _on_winner_screen_finished() -> void:
	if not multiplayer.is_server() or phase != Phase.ENDING:
		return

	if finishing_round:
		return
	finishing_round = true

	_continue_after_win()


func _continue_after_win() -> void:
	score_panel.start.rpc()
	await score_panel.finished

	if not is_inside_tree():
		return
	_reset_round()


func _reset_round() -> void:
	finishing_round = false

	phase = Phase.RESET

	players = Utils.player_children(self)
	players_killed.clear()
	damage_handler.reset_tables(players)

	for player: Player in players:
		damage_handler.replicate_state(player.name, player.max_health, false)
		pickup_handler.clear_player(player.name)

	dropped_spawner.clear_dropped_weapons()
	slipper_spawner.clear_all()

	for pickup in get_tree().get_nodes_in_group("weapon_pickup"):
		if pickup.has_method("reset_round"):
			pickup.reset_round()

	_begin_countdown()
