extends Node

signal names_synced()

@export var names: Dictionary[int, String] = {}


func request_add_name(id: int, player_name: String) -> void:
	_add_name.rpc_id(1, id, player_name)


@rpc("any_peer", "call_local", "reliable")
func _add_name(id: int, player_name: String) -> void:
	if not multiplayer.is_server():
		return
	
	names[id] = player_name
	
	for peer: int in multiplayer.get_peers():
		_sync_names.rpc_id(peer, names)
	
	names_synced.emit()


@rpc("any_peer", "call_local", "reliable")
func _sync_names(input_names: Dictionary):
	names = input_names
	names_synced.emit()
