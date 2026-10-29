extends Control


@export var player_card_scene: PackedScene
@export var back_target: StringName
@export var start_target: StringName


@onready var player_list: VBoxContainer = %PlayerList
@onready var server_ip_label: Label = $ServerIPLabel
@onready var start_button: AnimatedButton = $StartButton
@onready var ready_button: AnimatedButton = $ReadyButton
@onready var name_input: AnimatedLineEdit = $NameInput
@onready var name_save_button: AnimatedButton = $NameInput/NameSaveButton


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

	if multiplayer.is_server():
		start_button.disabled = true
		start_button.visible = true
	
	if NetworkManager.players.has(multiplayer.get_unique_id()):
		var is_ready: bool = NetworkManager.players[multiplayer.get_unique_id()].get("is_ready")
		if is_ready:
			ready_button.text = "Unready?"
		else:
			ready_button.text = "Ready!"

	_fill_name_input()


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
	
	var all_ready: bool = true
	for player_id in NetworkManager.players:
		if NetworkManager.players[player_id].get("is_ready") == false:
			all_ready = false
			break
	
	if multiplayer.multiplayer_peer == null:
		return

	if multiplayer.is_server() and all_ready:
		start_button.disabled = false

	if NetworkManager.players.has(multiplayer.get_unique_id()):
		var is_ready: bool = NetworkManager.players[multiplayer.get_unique_id()].get("is_ready")
		if is_ready:
			ready_button.text = "Unready?"
		else:
			ready_button.text = "Ready!"

	_fill_name_input()


func _on_ready_button_pressed() -> void:
	NetworkManager.request_ready_update(ready_button.text == "Ready!")


func _on_back_button_pressed() -> void:
	NetworkManager.leave_session()


func _on_start_button_pressed() -> void:
	NetworkManager.start_game(start_target)


func _on_name_save_button_pressed() -> void:
	var cleaned: String = name_input.text.strip_edges()

	if cleaned.is_empty():
		return

	NetworkManager.request_name_update(cleaned)
	name_input.release_focus()


func _fill_name_input() -> void:
	if name_input.has_focus():
		return

	var id: int = multiplayer.get_unique_id()
	if not NetworkManager.players.has(id):
		return

	name_input.text = str(NetworkManager.players[id].get("name", ""))
