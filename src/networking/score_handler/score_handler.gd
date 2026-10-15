class_name ScoreHandler
extends Node


@export var scores: Dictionary[int, int] = {}


@onready var score_panel: ScorePanel = %ScorePanel


func add_score(player_id: int, amount: int) -> void:
	if multiplayer.is_server() == false:
		return
	
	if scores.get(player_id) == null:
		scores[player_id] = 0
	
	scores[player_id] += amount
	_sync_score.rpc(player_id, scores[player_id])


@rpc("authority", "call_local", "reliable")
func _sync_score(player_id: int, score: int) -> void:
	scores[player_id] = score
	score_panel.set_player_score(player_id, score)
