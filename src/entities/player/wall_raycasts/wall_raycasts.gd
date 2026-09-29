class_name WallRaycasts
extends Node3D


var front_raycasts: Array[RayCast3D] = []
var right_raycasts: Array[RayCast3D] = []
var left_raycasts: Array[RayCast3D] = []


@onready var front: RayCast3D = $Front
@onready var front_bottom: RayCast3D = $FrontBottom
@onready var front_top: RayCast3D = $FrontTop
@onready var left: RayCast3D = $Left
@onready var left_bottom: RayCast3D = $LeftBottom
@onready var left_top: RayCast3D = $LeftTop
@onready var right: RayCast3D = $Right
@onready var right_bottom: RayCast3D = $RightBottom
@onready var right_top: RayCast3D = $RightTop


func _ready() -> void:
	front_raycasts = [front, front_bottom, front_top]
	right_raycasts = [right, right_bottom, right_top]
	left_raycasts = [left, left_bottom, left_top]


func is_colliding() -> bool:
	if _has_active_collision(front_raycasts):
		return true
	if _has_active_collision(left_raycasts):
		return true
	if _has_active_collision(right_raycasts):
		return true
	return false


func front_is_colliding() -> bool:
	return front.is_colliding()


func get_wall_normal() -> Vector3:
	var normal: Vector3 = Vector3.ZERO

	if _has_active_collision(front_raycasts):
		normal = _has_active_collision(front_raycasts).get_collision_normal()
	if _has_active_collision(left_raycasts):
		normal = _has_active_collision(left_raycasts).get_collision_normal()
	if _has_active_collision(right_raycasts):
		normal = _has_active_collision(right_raycasts).get_collision_normal()

	return normal


func _has_active_collision(x: Array[RayCast3D]) -> RayCast3D:
	var ret: RayCast3D = null

	for ray in x:
		if ray.is_colliding():
			ret = ray
			break

	return ret
