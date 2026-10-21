extends Node


signal players_changed()
signal peer_joined(id: int)
signal peer_left(id: int)
signal session_ended()


const IP_ADDR: String = "localhost"
const PORT: int = 8500
const MAX_PLAYERS: int = 8
const ACK_TIMEOUT: float = 5.0
const MAIN_MENU_SCENE: String = "res://src/ui/main_menu/main_menu.tscn"
const DEFAULT_NAMES: Array[String] = ["Host", "Player 2", "Player 3", "Player 4"]


var peer: ENetMultiplayerPeer
var players: Dictionary[int, Dictionary] = {}
var next_name_index: int = 0

var match_started: bool = false
var ending_session: bool = false
var rejected_peers: Dictionary[int, bool] = {}


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func start_server() -> Error:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(PORT, MAX_PLAYERS - 1)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	next_name_index = 0
	match_started = false
	ending_session = false
	rejected_peers.clear()
	self._add_player(multiplayer.get_unique_id(), _default_name())
	return OK


func start_client(ip: String = "") -> Error:
	if ip == "":
		ip = IP_ADDR
	
	peer = ENetMultiplayerPeer.new()
	var resolved_ip: String = IP.resolve_hostname(ip, IP.TYPE_IPV4)
	if resolved_ip.is_empty():
		return ERR_CANT_RESOLVE

	var error: Error = peer.create_client(resolved_ip, PORT)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	ending_session = false
	return OK


func abort_join() -> void:
	if peer == null:
		return
	peer.close()
	multiplayer.multiplayer_peer = null
	peer = null
	players.clear()


func leave_session() -> void:
	end_session()


func end_session() -> void:
	if ending_session:
		return
	ending_session = true

	if peer != null:
		peer.close()
		multiplayer.multiplayer_peer = null
		peer = null

	players.clear()
	rejected_peers.clear()

	next_name_index = 0
	match_started = false

	session_ended.emit()
	_load_main_menu()


func disconnect_client() -> void:
	leave_session()


func disconnect_server() -> void:
	leave_session()


func request_ready_update(is_ready: bool) -> void:
	_update_ready.rpc_id(1, is_ready)


func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()
	var candidates = []
	
	for addr in addresses:
		if ":" in addr or addr.begins_with("127."):
			continue

		if addr.begins_with("192.168.") or addr.begins_with("10."):
			candidates.push_front(addr) 
		elif not addr.begins_with("172.17.") and not addr.begins_with("169.254."):
			candidates.push_back(addr)
	
	return candidates[0] if candidates.size() > 0 else "127.0.0.1"


func _load_main_menu() -> void:
	var current := get_tree().current_scene
	if current and current.scene_file_path == MAIN_MENU_SCENE:
		return
	SceneLoader.load_scene(MAIN_MENU_SCENE)


func _default_name() -> String:
	var index := next_name_index
	next_name_index += 1
	if index < DEFAULT_NAMES.size():
		return DEFAULT_NAMES[index]
	return "Player %d" % (index + 1)


func _add_player(id: int, player_name: String) -> void:
	players[id] = {
		"name": player_name,
		"is_ready": false,
	}
	peer_joined.emit(id)
	_sync_players.rpc(players)


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return

	if match_started or players.size() >= MAX_PLAYERS:
		rejected_peers[id] = true
		peer.disconnect_peer(id)
		return

	_add_player(id, _default_name())


func _on_peer_disconnected(id: int) -> void:
	if ending_session:
		return
	if rejected_peers.erase(id):
		return

	if multiplayer.is_server():
		end_session()


func _on_server_disconnected() -> void:
	end_session()


@rpc("authority", "call_local", "reliable")
func _sync_players(data: Dictionary) -> void:
	var old_players: Dictionary = players.duplicate()
	players = data

	# Server already emitted these when it mutated the list.
	if not multiplayer.is_server():
		for id: int in players:
			if not old_players.has(id):
				peer_joined.emit(id)
		for id: int in old_players:
			if not players.has(id):
				peer_left.emit(id)

	players_changed.emit()


@rpc("any_peer", "call_local", "reliable")
func _update_ready(is_ready: bool) -> void:
	if not multiplayer.is_server():
		return

	var id: int = Utils.sender_id(self)

	if not players.has(id):
		return

	players[id]["is_ready"] = is_ready
	_sync_players.rpc(players)


func start_game(target: StringName) -> void:
	if not multiplayer.is_server():
		return
	match_started = true
	_sync_players.rpc(players)
	SceneLoader.load_scene.rpc(target)
