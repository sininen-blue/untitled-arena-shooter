extends Control


@export var player_card_scene: PackedScene
@export var start_button_target: StringName


@onready var server_ip_label: Label = $ServerIPLabel
@onready var player_list: VBoxContainer = %PlayerList


func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_client_joined)
		
		server_ip_label.text = NetworkManager.get_local_ip()
		_add_card(PlayerNames.names.get(multiplayer.get_unique_id()))
	else:
		PlayerNames.names_synced.connect(_on_names_synced)
		_client_joined(multiplayer.get_unique_id())


func _client_joined(id: int) -> void:
	if multiplayer.is_server():
		_add_card(PlayerNames.names.get(id, str(id)))
	else:
		PlayerNames.request_add_name(id, str(id))


func _on_names_synced() -> void:
	_reset_cards()
	for id in PlayerNames.names.keys():
		_add_card(PlayerNames.names.get(id))


func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		SceneLoader.load_scene.rpc(start_button_target)


func _add_card(player_name: String) -> void:
	var player_card_instance: PlayerCard = player_card_scene.instantiate()
	player_card_instance.player_name = player_name
	player_list.add_child(player_card_instance)


func _reset_cards() -> void:
	for child in player_list.get_children():
		child.queue_free()
