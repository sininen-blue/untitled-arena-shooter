class_name HitscanWeapon
extends Node3D


@export var damage: float = 1

@export var min_spread: float = 0
@export var max_spread: float = 0
@export var accuracy_curve: float = 0

@export var v_recoil: float = 0
@export var h_recoil: float = 0

@export var fire_rate: float = 0.2
@export var ammo = 20

@export var recoil_impulse: float = 0.25
@export var max_back_distance: float = 0.5
@export var max_angle: float = 15.0


var time: float = 0


func shoot() -> bool:
	if time <= 0 and ammo > 0:
		time = fire_rate
		ammo -= 1
		
		recoil()
		return true
	return false

# apply horizontal and vertical recoil
# look at player? change raycast angles?
# or do i want raycasts on the gun itself, :w
# shoot


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
