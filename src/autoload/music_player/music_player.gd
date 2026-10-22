extends Node


const ROUND_BACKGROUND_1 = preload("uid://bse0hf0106jpe")
const ROUND_BACKGROUND_2 = preload("uid://cvurphhxbwbks")
const ROUND_BACKGROUND_3 = preload("uid://dr3yq6gqs1rv8")


@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic
@onready var battle_music: AudioStreamPlayer = $BattleMusic
@onready var win_jingle: AudioStreamPlayer = $WinJingle
@onready var lose_jingle: AudioStreamPlayer = $LoseJingle
@onready var intro_jingle: AudioStreamPlayer = $IntroJingle
