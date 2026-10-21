extends Control


@export var host_button_target: StringName
@export var join_button_target: StringName

@onready var ip_input: LineEdit = $IPInput
@onready var error_label: Label = $ErrorLabel
@onready var join_button: Button = $JoinButton


func _ready() -> void:
	ip_input.grab_focus()
	join_button.disabled = ip_input.text == ""


func _on_host_button_pressed() -> void:
	var error: Error = NetworkManager.start_server()
	match error:
		OK:
			SceneLoader.load_scene(host_button_target)
		ERR_ALREADY_EXISTS:
			print("sever already hosting")
		ERR_ALREADY_IN_USE:
			print("port already in use")
		ERR_CANT_CREATE:
			print("could not create host")
	


func _on_join_button_pressed() -> void:
	var ip: String = ip_input.text
	join_button.disabled = true

	var connected := false
	var failed := false
	var on_connected := func() -> void: connected = true
	var on_failed := func() -> void: failed = true
	multiplayer.connected_to_server.connect(on_connected, CONNECT_ONE_SHOT)
	multiplayer.connection_failed.connect(on_failed, CONNECT_ONE_SHOT)

	var error: Error = NetworkManager.start_client(ip)
	if error != OK:
		_disconnect_join_wait(on_connected, on_failed)
		match error:
			ERR_CANT_RESOLVE:
				_show_join_error("Could not resolve that address")
			ERR_ALREADY_IN_USE:
				_show_join_error("Client already connected, please close")
			ERR_CANT_CREATE:
				_show_join_error("Could not create peer")
			_:
				_show_join_error("Could not connect")
		return

	var deadline := Time.get_ticks_msec() + int(NetworkManager.ACK_TIMEOUT * 1000.0)
	while not connected and not failed and not _join_is_connected() and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	_disconnect_join_wait(on_connected, on_failed)
	if connected or _join_is_connected():
		SceneLoader.load_scene(join_button_target)
		return
	NetworkManager.abort_join()
	_show_join_error("Could not connect")


func _join_is_connected() -> bool:
	var mp := multiplayer.multiplayer_peer
	return mp != null and mp.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func _disconnect_join_wait(on_connected: Callable, on_failed: Callable) -> void:
	if multiplayer.connected_to_server.is_connected(on_connected):
		multiplayer.connected_to_server.disconnect(on_connected)
	if multiplayer.connection_failed.is_connected(on_failed):
		multiplayer.connection_failed.disconnect(on_failed)


func _show_join_error(message: String) -> void:
	error_label.visible = true
	error_label.text = message
	join_button.disabled = ip_input.text == ""


func _on_ip_input_text_changed(new_text: String) -> void:
	join_button.disabled = new_text == ""
