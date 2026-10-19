class_name LandParticleSpawner
extends MultiplayerSpawner


@export var land_particle: PackedScene


@onready var land_particles: Node3D = %LandParticles


func _ready() -> void:
	self.spawn_function = _spawn_function


func request_spawn(location: Vector3) -> void:
	_spawn_particle.rpc_id(1, location)


func request_despawn(particle: LandParticle) -> void:
	_despawn_particle.rpc_id(1, particle.name)


@rpc("any_peer", "call_local", "reliable")
func _spawn_particle(location: Vector3) -> void:
	if not multiplayer.is_server():
		return

	var data: Dictionary[String, Vector3] = {
		"location": location,
	}
	spawn(data)


@rpc("any_peer", "call_local", "reliable")
func _despawn_particle(particle_name: String) -> void:
	if not multiplayer.is_server():
		return

	var particle: Node = land_particles.get_node_or_null(particle_name)
	if particle:
		particle.queue_free()


func _spawn_function(data: Dictionary) -> LandParticle:
	var land_particle_instance: LandParticle = land_particle.instantiate()

	land_particle_instance.spawner = self
	land_particle_instance.pending_position = data.get("location")

	return land_particle_instance
