class_name HitDecal
extends Decal


var pending_position: Vector3
var pending_normal: Vector3


func _ready() -> void:
	if pending_position:
		global_position = pending_position

	if pending_normal:
		self.global_transform.basis = Basis.looking_at(-pending_normal, Vector3.UP)
		self.rotation_degrees.x += 90
