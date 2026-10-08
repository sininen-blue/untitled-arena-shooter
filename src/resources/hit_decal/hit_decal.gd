class_name HitDecal
extends Decal


var pending_position: Vector3
var pending_normal: Vector3


@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D


func _ready() -> void:
	gpu_particles_3d.emitting = true
	gpu_particles_3d.rotation_degrees.y = -90
	gpu_particles_3d.rotation_degrees.z = 90

	
	if pending_position:
		global_position = pending_position

	if pending_normal:
		self.global_transform.basis = Basis.looking_at(-pending_normal, Vector3.UP)
		self.rotation_degrees.x += 90
