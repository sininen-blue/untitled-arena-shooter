extends Control


@export var start_button_target: StringName

@onready var server_ip_label: Label = $ServerIPLabel
@onready var player_one: Panel = $PlayerOne
@onready var player_one_name: Label = $PlayerOne/PlayerOneName


func _ready() -> void:
	if multiplayer.is_server():
		server_ip_label.text = NetworkManager.get_local_ip()
		multiplayer.peer_connected.connect(_client_joined)
	else:
		_client_joined(multiplayer.get_unique_id())


func _client_joined(id: int) -> void:
	player_one_name.text = str(id)
	player_one.visible = true


func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		SceneLoader.load_scene.rpc(start_button_target)
