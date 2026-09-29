class_name HitscanWeapon
extends Node3D


@export var damage: float = 1

@export var min_spread: float = 0
@export var max_spread: float = 0
@export var accuracy_curve: float = 0

@export var v_recoil: float = 0
@export var h_recoil: float = 0

@export var fire_rate: float = 0.02
@export var ammo = 0


var time: float = 0


func shoot() -> void:
	if time <= 0:
		time = fire_rate

# apply horizontal and vertical recoil
# look at player? change raycast angles?
# or do i want raycasts on the gun itself, :w
# shoot



func _process(delta: float) -> void:
	if time >= 0:
		time -= 1 * delta
