class_name PlayerSpawner
extends MultiplayerSpawner


signal all_players_spawned


@export var network_player: PackedScene
@export var debug: bool = false


var ready_peers: Array[int] = []


@onready var dropped_spawner: MultiplayerSpawner = $"../DroppedSpawner"


func _ready() -> void:
	self.spawn_function = _spawn_player


func start() -> void:
	if multiplayer.is_server():
		ready_peers.append(multiplayer.get_unique_id())
		_check_all_ready()
	else:
		_notify_ready.rpc_id(1)


@rpc("any_peer", "reliable")
func _notify_ready() -> void:
	if multiplayer.is_server() == false:
		return
	
	var id: int = multiplayer.get_remote_sender_id()
	ready_peers.append(id)
	_check_all_ready()


func _check_all_ready() -> void:
	var peers: PackedInt32Array = multiplayer.get_peers()
	peers.append(multiplayer.get_unique_id())
	
	if ready_peers.size() == peers.size():
		for id: int in ready_peers:
			self.spawn.call_deferred(id)

		all_players_spawned.emit()


func _spawn_player(id: int) -> Player:
	var player: Player = network_player.instantiate()
	player.name = str(id)
	
	return player
