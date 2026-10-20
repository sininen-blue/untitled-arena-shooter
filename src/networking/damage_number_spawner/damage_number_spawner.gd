class_name DamageNumberSpawner
extends MultiplayerSpawner


@export var damage_number_particle: PackedScene


@onready var damage_number_particles: Node3D = %DamageNumberParticles


func _ready() -> void:
	self.spawn_function = _spawn_function


func request_spawn(location: Vector3, damage: float) -> void:
	_spawn_particle.rpc_id(1, location, damage)


func request_despawn(particle: DamageNumberParticle) -> void:
	_despawn_particle.rpc_id(1, particle.name)


@rpc("any_peer", "call_local", "reliable")
func _spawn_particle(location: Vector3, damage: float) -> void:
	if not multiplayer.is_server():
		return

	var data: Dictionary = {
		"location": location,
		"damage": damage,
	}
	spawn(data)


@rpc("any_peer", "call_local", "reliable")
func _despawn_particle(particle_name: String) -> void:
	if not multiplayer.is_server():
		return

	var particle: Node = damage_number_particles.get_node_or_null(particle_name)
	if particle:
		particle.queue_free()


func _spawn_function(data: Dictionary) -> DamageNumberParticle:
	var damage_number_instance: DamageNumberParticle = damage_number_particle.instantiate()

	damage_number_instance.spawner = self
	damage_number_instance.pending_position = data.get("location")
	damage_number_instance.pending_damage = data.get("damage")

	return damage_number_instance
