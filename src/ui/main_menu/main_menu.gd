extends Control


@export var host_button_target: StringName
@export var join_button_target: StringName

@onready var ip_input: LineEdit = $IPInput
@onready var error_label: Label = $ErrorLabel
@onready var join_button: Button = $JoinButton


func _ready() -> void:
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
	
	var error: Error = NetworkManager.start_client(ip)
	match error:
		OK:
			SceneLoader.load_scene(join_button_target)
		ERR_ALREADY_IN_USE:
			error_label.visible = true
			error_label.text = "Client already connected, please close"
		ERR_CANT_CREATE:
			error_label.visible = true
			error_label.text = "Could not create peer"


func _on_ip_input_text_changed(new_text: String) -> void:
	join_button.disabled = new_text == ""
