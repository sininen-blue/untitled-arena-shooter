class_name HitscanWeapon
extends Node3D


@export var damage: float = 1

@export var max_spread: float = 1.2
@export var spread_recovery: float = 3.0

@export var head_recoil: float = 5.0
@export var max_head_recoil: float = 80.0
@export var head_recoil_recovery: float = 3.0

@export var fire_rate: float = 0.2
@export var ammo = 20

@export var recoil_impulse: float = 0.25
@export var max_back_distance: float = 0.5
@export var max_angle: float = 15.0


var time: float = 0


func can_shoot() -> bool:
	if time <= 0 and ammo > 0:
		return true
	return false


func shoot() -> void:
	time = fire_rate
	ammo -= 1
	
	recoil()


func apply_spread(ray: RayCast3D) -> void:
	var horizontal_spread: float = randf_range(-max_spread, max_spread)
	var vertical_spread: float = randf_range(-max_spread, max_spread)
	
	ray.rotation_degrees.y = vertical_spread
	ray.rotation_degrees.x = horizontal_spread


func apply_spread_recovery(ray: RayCast3D, delta: float) -> void:
	ray.rotation = Utils.exp_decay(ray.rotation, Vector3.ZERO, spread_recovery, delta)



# recoil increases back
# the slowly go back to center
func recoil() -> void:
	if self.position.z < max_back_distance:
		self.position.z += recoil_impulse
	
	if self.rotation.x < max_angle:
		self.rotation.x += recoil_impulse/2



func _process(delta: float) -> void:
	if time >= 0:
		time -= 1 * delta
	
	if position.z > 0:
		self.position.z = Utils.exp_decay(self.position.z, 0, 3, delta)
	if rotation.x > 0:
		self.rotation.x = Utils.exp_decay(self.rotation.x, 0, 7, delta)
