class_name PlayerSpawner
extends MultiplayerSpawner


signal all_players_spawned


@export var network_player: PackedScene


var to_spawn: int = 0
var has_spawned: int = 0


func _ready() -> void:
	self.spawn_function = _spawn_player


func start() -> void:
	if not multiplayer.is_server():
		return
	
	to_spawn = NetworkManager.players.size()
	
	for player_id: int in NetworkManager.players:
		spawn.call_deferred(player_id)


func _spawn_player(id: int) -> Player:
	var player: Player = network_player.instantiate()
	player.name = str(id)
	
	player.ready.connect(_on_player_ready)
	return player


func _on_player_ready() -> void:
	has_spawned += 1
	if has_spawned == to_spawn:
		all_players_spawned.emit()
