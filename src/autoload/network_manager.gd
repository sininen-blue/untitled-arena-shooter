extends Node


signal players_changed()
signal peer_joined(id: int)
signal peer_left(id: int)


const IP_ADDR: String = "localhost"
const PORT: int = 8500


var peer: ENetMultiplayerPeer
var players: Dictionary[int, Dictionary] = {}


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)


func start_server() -> Error:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(PORT)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	self._add_player(multiplayer.get_unique_id(), "Host")
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
	return OK


func disconnect_client() -> void:
	if peer == null or multiplayer.is_server():
		return

	peer.close()
	multiplayer.multiplayer_peer = null
	peer = null

	var ids: Array = players.keys()
	players.clear()
	for id: int in ids:
		peer_left.emit(id)
	players_changed.emit()


func disconnect_server() -> void:
	if peer == null or not multiplayer.is_server():
		return

	peer.close()
	multiplayer.multiplayer_peer = null
	peer = null
	players.clear()


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
	_add_player(id, "Player " + str(id))


func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server():
		return
	players.erase(id)
	peer_left.emit(id)
	_sync_players.rpc(players)


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

	var id: int = multiplayer.get_remote_sender_id()
	if id == 0:
		id = multiplayer.get_unique_id()

	players[id].set("is_ready", is_ready)
	_sync_players.rpc(players)
	
