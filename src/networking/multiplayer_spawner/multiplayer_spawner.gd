extends MultiplayerSpawner


@export var network_player: PackedScene


func spawn_player(id: int) -> void:
	if multiplayer.is_server() == false:
		return
	
	var player: Player = network_player.instantiate()
	player.name = str(id)
	
	get_node(self.spawn_path).add_child.call_deferred(player)
