class_name RunParticle
extends GPUParticles3D


var rest_position: Vector3


func _ready() -> void:
	rest_position = position


func start() -> void:
	self.emitting = true


func stop() -> void:
	self.emitting = false


func move_to(world_position: Vector3) -> void:
	global_position = world_position


func reset_position() -> void:
	position = rest_position
