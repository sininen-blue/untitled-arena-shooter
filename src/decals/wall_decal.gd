@tool
class_name WallDecal
extends Decal

func _ready() -> void:
	self.cull_mask &= ~(1 << 9)
