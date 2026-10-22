class_name AmmoCount
extends Control


@export var player: Player
@export var bump_scale: float = 1.4
@export var bump_rise: float = -12.0
@export var bump_rotation: float = 16.0
@export var tilt_recovery: float = 2.0


@onready var label: Label = $CurrentAmmo


var current_ammo: int = -1
var tracked_weapon: HitscanWeapon
var bump_tween: Tween
var rest_position: Vector2


func _ready() -> void:
	label.offset_transform_enabled = true
	rest_position = label.position
	label.pivot_offset = label.size * 0.5
	visible = false


func _process(_delta: float) -> void:
	if label.pivot_offset == Vector2.ZERO and label.size != Vector2.ZERO:
		label.pivot_offset = label.size * 0.5

	_sync_from_player()
	label.offset_transform_rotation = Utils.exp_decay(label.offset_transform_rotation, 0.0, tilt_recovery, _delta)


func _sync_from_player() -> void:
	if tracked_weapon != null and not is_instance_valid(tracked_weapon):
		tracked_weapon = null

	var weapon: HitscanWeapon = null
	if player != null and is_instance_valid(player.current_weapon):
		weapon = player.current_weapon

	var picked_up := weapon != tracked_weapon
	tracked_weapon = weapon

	var ammo := 0
	if weapon != null:
		ammo = int(weapon.ammo)

	if not picked_up and ammo == current_ammo:
		return

	_set_current_ammo(ammo, picked_up)


func _set_current_ammo(new_val: int, picked_up: bool) -> void:
	var changed := new_val != current_ammo
	current_ammo = new_val
	label.text = str(maxi(current_ammo, 0))

	if current_ammo <= 0:
		visible = false
		_reset_label()
		return

	visible = true
	if changed or picked_up:
		_bump()


func _bump() -> void:
	if not is_inside_tree():
		return

	if bump_tween and bump_tween.is_valid():
		bump_tween.kill()

	_reset_label()
	var tilt := deg_to_rad(randf_range(bump_rotation * 0.6, bump_rotation))
	if randf() < 0.5:
		tilt = -tilt
	label.offset_transform_rotation += tilt

	bump_tween = create_tween()
	bump_tween.set_ease(Tween.EASE_OUT)
	bump_tween.set_trans(Tween.TRANS_BACK)

	bump_tween.tween_property(label, "offset_transform_scale", Vector2(bump_scale, bump_scale), 0.08)
	bump_tween.parallel().tween_property(label, "position", rest_position + Vector2(0.0, bump_rise), 0.08)

	bump_tween.tween_property(label, "offset_transform_scale", Vector2.ONE, 0.14)
	bump_tween.parallel().tween_property(label, "position", rest_position, 0.14)


func _reset_label() -> void:
	label.position = rest_position
	label.offset_transform_scale = Vector2.ONE
