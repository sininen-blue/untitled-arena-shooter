class_name Crosshair
extends Node2D


@export var player: Player
@export var spread_weight: float = 6.0
@export var spread_decay: float = 2.0


@onready var top_left: Sprite2D = $TopLeft
@onready var bottom_left: Sprite2D = $BottomLeft
@onready var bottom_right: Sprite2D = $BottomRight
@onready var top_right: Sprite2D = $TopRight


var _rest_positions: Dictionary[Sprite2D, Vector2] = {}


func _ready() -> void:
	global_position = get_viewport_rect().size * 0.5
	for sprite in [top_left, bottom_left, bottom_right, top_right]:
		_rest_positions[sprite] = sprite.position


func _process(delta: float) -> void:
	var spread := 0.0
	if player and player.current_weapon:
		var weapon := player.current_weapon
		spread = clampf(weapon.current_spread, weapon.min_spread, weapon.max_spread)

	for sprite in _rest_positions:
		var rest: Vector2 = _rest_positions[sprite]
		var target := rest.normalized() * (rest.length() + spread * spread_weight)
		sprite.position = Utils.exp_decay(sprite.position, target, spread_decay, delta)
