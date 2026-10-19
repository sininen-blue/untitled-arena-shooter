class_name HitDecal
extends Decal


@export var lifetime: float = 5.0
@export var fade_duration: float = 1.0


var spawner: DecalSpawner
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
		var up := Vector3.UP
		if absf(pending_normal.normalized().dot(Vector3.UP)) > 0.999:
			up = Vector3.RIGHT

		global_transform.basis = Basis.looking_at(-pending_normal, up)
		rotation_degrees.x += 90

	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


func _on_lifetime_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	if multiplayer.is_server():
		tween.finished.connect(func() -> void: spawner.request_despawn(self))
