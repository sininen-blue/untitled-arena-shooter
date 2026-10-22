extends Node


const ROUND_BACKGROUND_1: AudioStream = preload("uid://bse0hf0106jpe")
const ROUND_BACKGROUND_2: AudioStream = preload("uid://cvurphhxbwbks")
const ROUND_BACKGROUND_3: AudioStream = preload("uid://dr3yq6gqs1rv8")

const MENU_SCENES: Array[String] = [
	"res://src/ui/main_menu/main_menu.tscn",
	"res://src/ui/lobby/lobby.tscn",
]
const FADE_IN: float = 0.7
const FADE_OUT: float = 0.45
const SILENT_DB: float = -36.0


enum Mode { NONE, MENU, INTRO, BATTLE, WIN, LOSE }


@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic
@onready var battle_music: AudioStreamPlayer = $BattleMusic
@onready var win_jingle: AudioStreamPlayer = $WinJingle
@onready var lose_jingle: AudioStreamPlayer = $LoseJingle
@onready var intro_jingle: AudioStreamPlayer = $IntroJingle


var mode: Mode = Mode.NONE
var fade_tween: Tween
var fade_generation: int = 0
var last_battle_index: int = -1
var pending_battle_index: int = -1
var countdown_finished: bool = false


func _ready() -> void:
	get_tree().scene_changed.connect(_sync_scene)
	call_deferred("_sync_scene")


func begin_round() -> void:
	if multiplayer.multiplayer_peer != null and not multiplayer.is_server():
		return

	var index: int = _pick_battle_index()
	if multiplayer.multiplayer_peer == null:
		_begin_round(index)
		return

	_begin_round.rpc(index)


func on_countdown_finished() -> void:
	countdown_finished = true
	if pending_battle_index < 0:
		return
	_play_battle(pending_battle_index)


func announce_round_result(winner_id: int) -> void:
	if multiplayer.multiplayer_peer == null:
		_apply_round_result(winner_id)
		return
	_apply_round_result.rpc(winner_id)


func _sync_scene() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	if scene.scene_file_path in MENU_SCENES:
		_play_main_menu()


func _play_main_menu() -> void:
	if mode == Mode.MENU and main_menu_music.playing:
		return
	mode = Mode.MENU
	pending_battle_index = -1
	countdown_finished = false
	_crossfade_to(main_menu_music, false)


@rpc("authority", "call_local", "reliable")
func _begin_round(index: int) -> void:
	var already_finished: bool = countdown_finished
	pending_battle_index = index
	countdown_finished = false
	last_battle_index = index
	mode = Mode.INTRO
	_crossfade_to(intro_jingle, true)
	if already_finished:
		_play_battle(index)


@rpc("authority", "call_local", "reliable")
func _apply_round_result(winner_id: int) -> void:
	var won: bool = multiplayer.get_unique_id() == winner_id
	var jingle: AudioStreamPlayer = win_jingle if won else lose_jingle
	mode = Mode.WIN if won else Mode.LOSE
	pending_battle_index = -1
	_crossfade_to(jingle, true)


func _play_battle(index: int) -> void:
	var tracks: Array[AudioStream] = _round_tracks()
	if tracks.is_empty():
		return
	mode = Mode.BATTLE
	battle_music.stream = tracks[clampi(index, 0, tracks.size() - 1)]
	_crossfade_to(battle_music, true)


func _pick_battle_index() -> int:
	var tracks: Array[AudioStream] = _round_tracks()
	if tracks.is_empty():
		return 0
	if tracks.size() == 1:
		return 0
	var index: int = last_battle_index
	while index == last_battle_index:
		index = randi() % tracks.size()
	return index


func _round_tracks() -> Array[AudioStream]:
	return [ROUND_BACKGROUND_1, ROUND_BACKGROUND_2, ROUND_BACKGROUND_3]


func _players() -> Array[AudioStreamPlayer]:
	return [main_menu_music, battle_music, win_jingle, lose_jingle, intro_jingle]


func _crossfade_to(next: AudioStreamPlayer, restart: bool) -> void:
	if next == null:
		return
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()

	fade_generation += 1
	var generation: int = fade_generation

	if restart or not next.playing:
		next.volume_db = SILENT_DB
		next.play()

	fade_tween = create_tween()
	for player: AudioStreamPlayer in _players():
		if player == next:
			fade_tween.parallel().tween_property(player, "volume_db", 0.0, FADE_IN)
		elif player.playing:
			fade_tween.parallel().tween_property(player, "volume_db", SILENT_DB, FADE_OUT)

	fade_tween.chain().tween_callback(func() -> void:
		if generation != fade_generation:
			return
		for player: AudioStreamPlayer in _players():
			if player == next:
				continue
			player.stop()
			player.volume_db = 0.0
	)
