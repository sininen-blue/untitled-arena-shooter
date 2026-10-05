class_name ScoreHandler
extends Node


@export var scores: Dictionary[int, int] = {}


@onready var label: Label = $"../GlobalHud/Control/Label"


func add_score(player_id: int, amount: int) -> void:
	if multiplayer.is_server() == false:
		return
	
	if scores.get(player_id) == null:
		scores[player_id] = 0
	
	scores[player_id] += amount


func _process(delta: float) -> void:
	label.text = "scores: " + str(scores)
