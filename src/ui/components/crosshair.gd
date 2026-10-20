class_name Crosshair
extends Node2D


@export var player: Player
@export var spread_weight: float = 6.0
@export var spread_decay: float = 2.0


@onready var top_left: Sprite2D = $TopLeft
@onready var bottom_left: Sprite2D = $BottomLeft
@onready var bottom_right: Sprite2D = $BottomRight
@onready var top_right: Sprite2D = $TopRight

@onready var hitmarker: Sprite2D = $Hitmarker
@onready var hitmarker_sound: AudioStreamPlayer3D = $HitmarkerSound


var rest_positions: Dictionary[Sprite2D, Vector2] = {}
var hitmarker_tween: Tween
var hitmarker_scale: Vector2


func _ready() -> void:
	global_position = get_viewport_rect().size * 0.5
	for sprite in [top_left, bottom_left, bottom_right, top_right]:
		rest_positions[sprite] = sprite.position
	hitmarker_scale = hitmarker.scale
	hitmarker.visible = false


func show_hitmarker() -> void:
	hitmarker.visible = true
	hitmarker.scale = hitmarker_scale

	if hitmarker_tween:
		hitmarker_tween.kill()

	hitmarker_tween = create_tween()
	hitmarker_tween.tween_property(hitmarker, "scale", hitmarker_scale * 1.5, 0.08)
	hitmarker_tween.tween_property(hitmarker, "scale", hitmarker_scale * 0.85, 0.1)
	hitmarker_tween.tween_callback(func() -> void:
		hitmarker.visible = false
		hitmarker.scale = hitmarker_scale
	)

	hitmarker_sound.play()


func _process(delta: float) -> void:
	var spread := 0.0
	if player and player.current_weapon:
		var weapon := player.current_weapon
		spread = clampf(weapon.current_spread, weapon.min_spread, weapon.max_spread)

	for sprite in rest_positions:
		var rest: Vector2 = rest_positions[sprite]
		var target := rest.normalized() * (rest.length() + spread * spread_weight)
		sprite.position = Utils.exp_decay(sprite.position, target, spread_decay, delta)
