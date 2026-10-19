class_name JumpParticle
extends GPUParticles3D


@export var spawner: JumpParticleSpawner


var pending_position: Vector3


func _ready() -> void:
	self.emitting = true

	if pending_position:
		global_position = pending_position


func _on_finished() -> void:
	spawner.request_despawn(self)
