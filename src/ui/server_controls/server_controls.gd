extends Control

@export var player_card: PackedScene
@export var start_game_target: StringName


@onready var player_list: VBoxContainer = %PlayerList
@onready var player_list_spawner: MultiplayerSpawner = %PlayerListSpawner


func _ready() -> void:
	player_list_spawner.spawn_function = _spawn_player_card
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)	


func _on_multiplayer_peer_connected(id: int) -> void:
	if multiplayer.is_server() == false:
		return
	
	player_list_spawner.spawn(id)


func _on_start_server_pressed() -> void:
	NetworkManager.start_server()
	
	if multiplayer.is_server():
		player_list_spawner.spawn(multiplayer.get_unique_id())


func _on_join_game_pressed() -> void:
	NetworkManager.start_client()


func _on_start_game_pressed() -> void:
	if multiplayer.is_server():
		SceneLoader.load_scene.rpc(start_game_target)


func _spawn_player_card(id: int) -> Label:
	var label_instance: Label = player_card.instantiate()
	label_instance.text = str(id)
	return label_instance
