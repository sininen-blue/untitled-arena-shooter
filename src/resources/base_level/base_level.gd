class_name BaseLevel
extends Node


@export var spawn_locations: Array[Vector3]


func _ready() -> void:
	for child: Node in get_children():
		if child is Marker3D:
			spawn_locations.append(child.global_position)
