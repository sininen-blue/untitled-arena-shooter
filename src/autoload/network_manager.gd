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
	players = data
	players_changed.emit()
