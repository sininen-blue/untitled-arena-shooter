class_name HitDecal
extends Decal


const PLAYER_HIT = preload("uid://pcchch5qrrin")


@export var no_decal: bool = false
@export var lifetime: float = 5.0
@export var fade_duration: float = 1.0
@export var random_rotation_degrees: float = 90


var spawner: DecalSpawner
var pending_position: Vector3
var pending_normal: Vector3
var pending_no_decal: bool


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
		
		
		var angle := deg_to_rad(randf_range(-random_rotation_degrees, random_rotation_degrees))
		global_rotate(pending_normal.normalized(), angle)
	
	
	if pending_no_decal == true:
		no_decal = pending_no_decal
		self.texture_albedo = null
		gpu_particles_3d.material_overlay = PLAYER_HIT
	
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


func _on_lifetime_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	if multiplayer.is_server():
		tween.finished.connect(func() -> void: spawner.request_despawn(self))
