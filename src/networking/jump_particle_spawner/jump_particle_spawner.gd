class_name JumpParticleSpawner
extends MultiplayerSpawner


@export var jump_particle: PackedScene


@onready var jump_particles: Node3D = %JumpParticles


func _ready() -> void:
	self.spawn_function = _spawn_function


func request_spawn(location: Vector3, normal: Vector3) -> void:
	_spawn_particle.rpc_id(1, location, normal)


func request_despawn(particle: JumpParticle) -> void:
	_despawn_particle.rpc_id(1, particle.name)


@rpc("any_peer", "call_local", "reliable")
func _spawn_particle(location: Vector3, normal: Vector3) -> void:
	if not multiplayer.is_server():
		return

	var data: Dictionary[String, Vector3] = {
		"location": location,
		"normal": normal,
	}
	spawn(data)


@rpc("any_peer", "call_local", "reliable")
func _despawn_particle(particle_name: String) -> void:
	if not multiplayer.is_server():
		return

	var particle: Node = jump_particles.get_node_or_null(particle_name)
	if particle:
		particle.queue_free()


func _spawn_function(data: Dictionary) -> JumpParticle:
	var jump_particle_instance: JumpParticle = jump_particle.instantiate()

	jump_particle_instance.spawner = self
	jump_particle_instance.pending_position = data.get("location")
	jump_particle_instance.pending_normal = data.get("normal")

	return jump_particle_instance
