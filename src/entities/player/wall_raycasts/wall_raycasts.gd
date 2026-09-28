class_name WallRaycasts
extends Node3D


@onready var front: RayCast3D = $Front
@onready var left: RayCast3D = $Left
@onready var right: RayCast3D = $Right


func is_colliding() -> bool:
	if front.is_colliding():
		return true
	if left.is_colliding():
		return true
	if right.is_colliding():
		return true
	return false


func front_is_colliding() -> bool:
	return front.is_colliding()
