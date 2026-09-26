extends Node


const IP_ADDR: String = "localhost"
const PORT: int = 8500

var peer: ENetMultiplayerPeer


func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer


func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDR, PORT)
	multiplayer.multiplayer_peer = peer
