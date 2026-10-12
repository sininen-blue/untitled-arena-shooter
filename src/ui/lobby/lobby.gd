extends Control


@export var player_card_scene: PackedScene
@export var back_target: StringName
@export var start_target: StringName


@onready var player_list: VBoxContainer = %PlayerList
@onready var server_ip_label: Label = $ServerIPLabel


func _ready() -> void:
	server_ip_label.text = NetworkManager.get_local_ip()

	NetworkManager.peer_joined.connect(_on_peer_joined)
	NetworkManager.peer_left.connect(_on_peer_left)
	NetworkManager.players_changed.connect(_on_players_changed)

	if NetworkManager.players:
		for player_id in NetworkManager.players:
			var player_name: String = NetworkManager.players[player_id].get("name")
			var is_ready: bool = NetworkManager.players[player_id].get("is_ready")
			_add_player_card(player_id, player_name, is_ready)


func _add_player_card(id: int, player_name: String, is_ready: bool) -> void:
	var player_card_instance: PlayerCard = player_card_scene.instantiate()
	player_card_instance.player_id = id
	player_card_instance.player_name = player_name
	player_card_instance.is_ready = is_ready

	player_list.add_child(player_card_instance)


func _on_peer_joined(id: int) -> void:
	var player_name: String = NetworkManager.players[id].get("name")
	var is_ready: bool = NetworkManager.players[id].get("is_ready")
	_add_player_card(id, player_name, is_ready)


func _on_peer_left(id: int) -> void:
	for card: PlayerCard in player_list.get_children():
		if card.player_id == id:
			card.remove()
			return


func _on_players_changed() -> void:
	for card: PlayerCard in player_list.get_children():
		if not NetworkManager.players.has(card.player_id):
			continue

		card.player_name = NetworkManager.players[card.player_id].get("name")
		card.is_ready = NetworkManager.players[card.player_id].get("is_ready")


func _on_back_button_pressed() -> void:
	NetworkManager.disconnect_client()
	SceneLoader.load_scene(back_target)
