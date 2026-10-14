class_name ScorePanel
extends Panel


signal finished()


@export var player_score_card_scene: PackedScene


@onready var score_container: VBoxContainer = %ScoreContainer


func _ready() -> void:
	self.visible = false # NOTE: debug
	if NetworkManager.players:
		for player_id in NetworkManager.players:
			var player_name: String = NetworkManager.players[player_id].get("name")
			_spawn_player_score_card(player_name)


@rpc("any_peer", "call_local", "reliable")
func start() -> void:
	self.offset_transform_enabled = true

	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	tween.tween_property(self, "visible", true, 0.1)
	tween.tween_property(self, "offset_transform_scale", Vector2(1.2, 1.2), 1.0)

	tween.tween_await(get_tree().create_timer(2).timeout)

	tween.tween_property(self, "offset_transform_scale", Vector2(1.0, 1.0), 1.5)
	tween.tween_property(self, "visible", false, 0.1)

	await tween.finished
	finished.emit()


func _spawn_player_score_card(player_name: String) -> void:
	var player_score_card_instance: PlayerScoreCard = player_score_card_scene.instantiate()
	player_score_card_instance.player_name = player_name

	score_container.add_child(player_score_card_instance)
