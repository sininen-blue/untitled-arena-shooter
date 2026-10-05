class_name HitDecal
extends Decal


var pending_position


func _ready() -> void:
	if pending_position:
		global_position = pending_position
