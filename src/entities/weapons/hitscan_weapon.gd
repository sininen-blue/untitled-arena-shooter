class_name HitscanWeapon
extends Node3D

signal shot()

@export_group("Main Stats")
@export var damage: float = 1
@export var fire_rate: float = 0.2
@export var ammo = 20
@export var projectiles = 10


@export_group("Spread")
@export var min_spread: float = 0.5
@export var max_spread: float = 10.0
@export var max_speed: float = 7
@export var min_speed: float = 2
@export var speed_spread_curve: Curve
@export var spread_recovery: float = 3.0

@export_group("Recoil")
@export var head_recoil: float = 5.0
@export var max_head_recoil: float = 80.0
@export var head_recoil_recovery: float = 3.0

@export_group("Blowback")
@export var recoil_impulse: float = 0.25
@export var no_ammo_blowback: float = 0.08
@export var max_back_distance: float = 0.5
@export var max_angle: float = 15.0

@export_group("TIlts")
@export var x_tilt_strength: float = 20.0
@export var y_tilt_strength: float = 2.0

@export_group("References")
@export var muzzle: Marker3D
@export var player: Player

@export_group("Sounds")
@export var sound_player: AudioStreamPlayer3D
@export var no_ammo_player: AudioStreamPlayer3D


var current_spread: float = 0.0
var time: float = 0
var held: bool = false
var recoil_pending: bool = false
var pending_blowback: float = 0.0


func can_shoot() -> bool:
	if time <= 0 and ammo > 0:
		return true
	return false


func shoot() -> void:
	time = fire_rate
	ammo -= 1
	_queue_blowback(recoil_impulse)
	shot.emit()

	if player:
		player.play_weapon_sound()
	elif sound_player:
		sound_player.play()


func dry_fire() -> void:
	if ammo > 0 or time > 0:
		return

	time = fire_rate
	_queue_blowback(no_ammo_blowback)

	if player:
		player.play_no_ammo_sound()
	elif no_ammo_player:
		no_ammo_player.play()


func _queue_blowback(amount: float) -> void:
	pending_blowback = amount
	recoil_pending = true


func update_spread(player_speed: float) -> void:
	if player and (player.is_sliding or player.is_zoomed):
		current_spread = min_spread
		return

	var clamped_player_speed: float = 0.0
	if player_speed >= min_speed:
		clamped_player_speed = clampf(player_speed, min_speed, max_speed)

	var sample_point: float = 0.0
	if max_speed != min_speed:
		sample_point = (clamped_player_speed - min_speed) / (max_speed - min_speed)

	var speed_weight: float = 0.0
	if speed_spread_curve:
		speed_weight = speed_spread_curve.sample(sample_point)

	current_spread = min_spread + ((max_spread - min_spread) * speed_weight)


func apply_spread(ray: RayCast3D, player_speed: float) -> void:
	update_spread(player_speed)

	var horizontal_spread: float = randf_range(-current_spread, current_spread)
	var vertical_spread: float = randf_range(-current_spread, current_spread)
	
	ray.rotation_degrees.y = vertical_spread
	ray.rotation_degrees.x = horizontal_spread


func apply_spread_recovery(ray: RayCast3D, delta: float) -> void:
	ray.rotation = Utils.exp_decay(ray.rotation, Vector3.ZERO, spread_recovery, delta)



# recoil increases back
# the slowly go back to center
func recoil() -> void:
	var impulse := pending_blowback
	if self.position.z < max_back_distance:
		self.position.z = minf(self.position.z + impulse, max_back_distance)

	var kick := rad_to_deg(impulse * 0.5)
	if self.rotation_degrees.x < max_angle:
		self.rotation_degrees.x = minf(self.rotation_degrees.x + kick, max_angle)



func _process(delta: float) -> void:
	if player:
		update_spread(player.get_speed())

	if time >= 0:
		time -= 1 * delta
	
	if held:
		if position.z > 0:
			self.position.z = Utils.exp_decay(self.position.z, 0, 3, delta)
		if rotation.x > 0:
			self.rotation.x = Utils.exp_decay(self.rotation.x, 0, 7, delta)


func _physics_process(delta: float) -> void:
	if player:
		var local_dir: Vector3 = player.basis.inverse() * player.direction
		
		var hori_target: float = local_dir.x * x_tilt_strength
		var vert_target: float = -player.velocity.y * y_tilt_strength
		self.rotation_degrees.y = Utils.exp_decay(self.rotation_degrees.y, hori_target, 2, delta)
		self.rotation_degrees.x = Utils.exp_decay(self.rotation_degrees.x, vert_target, 2, delta)

	if recoil_pending:
		recoil()
		recoil_pending = false
