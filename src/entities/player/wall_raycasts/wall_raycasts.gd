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


func get_wall_normal() -> Vector3:
	var normal: Vector3 = Vector3.ZERO

	if front.is_colliding():
		normal = front.get_collision_normal()
	if left.is_colliding():
		normal = left.get_collision_normal()
	if right.is_colliding():
		normal = right.get_collision_normal()

	return normal
