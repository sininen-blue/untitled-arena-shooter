extends Node


const IP_ADDR: String = "localhost"
const PORT: int = 8500

var peer: ENetMultiplayerPeer


func start_server() -> Error:
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(PORT)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	return OK


func start_client(ip: String = "") -> Error:
	if ip == "":
		ip = IP_ADDR
	
	peer = ENetMultiplayerPeer.new()
	# TODO: resolve ip first, then resovle connection afterwards
	# place two errors here
	var error: Error = peer.create_client(ip, PORT)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	return OK


func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()
	for addr in addresses:
		if not addr.begins_with("127.") and ":" not in addr:
			return addr
	return "127.0.0.1" 
