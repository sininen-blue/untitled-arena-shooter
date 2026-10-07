class_name PlayerCard
extends Panel


@export var player_name: String = "":
	set = _set_player_name


@onready var label: Label = $Label


func _ready() -> void:
	label.text = player_name


func _set_player_name(new_text: String) -> void:
	player_name = new_text
	
	if label:
		label.text = player_name
