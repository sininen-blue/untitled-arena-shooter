class_name Slipper
extends RigidBody3D


@export var sender_immunity_duration: float = 0.2


var sender: int
var pending_position: Vector3
var pending_impulse: Vector3


func _ready() -> void:
	if pending_position:
		global_position = pending_position

	if pending_impulse:
		apply_central_impulse(pending_impulse)
