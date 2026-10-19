class_name JumpParticle
extends GPUParticles3D


@export var spawner: JumpParticleSpawner


var pending_position: Vector3
var pending_normal: Vector3


func _ready() -> void:
	if pending_position:
		global_position = pending_position

	if pending_normal:
		global_transform.basis = _basis_from_normal(pending_normal)

	self.emitting = true


func _basis_from_normal(normal: Vector3) -> Basis:
	var y := normal.normalized()
	var x := Vector3.UP.cross(y)
	if x.length_squared() < 0.0001:
		x = Vector3.RIGHT.cross(y)
	x = x.normalized()
	var z := x.cross(y).normalized()
	return Basis(x, y, z)


func _on_finished() -> void:
	spawner.request_despawn(self)
