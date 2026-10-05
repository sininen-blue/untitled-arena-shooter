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
	var candidates = []
	
	for addr in addresses:
		if ":" in addr or addr.begins_with("127."):
			continue
		# Prefer typical LAN ranges
		if addr.begins_with("192.168.") or addr.begins_with("10."):
			candidates.push_front(addr)  # highest priority
		elif not addr.begins_with("172.17.") and not addr.begins_with("169.254."):
			candidates.push_back(addr)   # lower priority fallback
	
	return candidates[0] if candidates.size() > 0 else "127.0.0.1"
