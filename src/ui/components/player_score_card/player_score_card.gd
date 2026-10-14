class_name PlayerScoreCard
extends HBoxContainer

@export var player_name: String = "Player":
	set = _set_player_name
@export var player_score: int = 0:
	set = _set_player_score


@onready var name_label: Label = $NameLabel
@onready var score_label: Label = $ScoreLabel


func _ready() -> void:
	name_label.text = player_name
	score_label.text = str(player_score)


func _set_player_name(new_name: String) -> void:
	player_name = new_name
	
	if name_label:
		name_label.text = player_name


func _set_player_score(new_score: int) -> void:
	player_score = new_score
	
	if score_label:
		score_label.text = str(new_score)
