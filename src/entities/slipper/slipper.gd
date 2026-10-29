class_name Slipper
extends RigidBody3D


@export var sender_immunity_duration: float = 0.2
@export var bounce_despawn_duration: float = 2.0
@export var spawner: SlipperSpanwner


var sender: int
var pending_position: Vector3
var pending_impulse: Vector3

var can_bounce: bool = true
var has_sender_immune: bool = true
var particles_stopped: bool = false
var immunity_left: float = 0.0


@onready var despawn_timer: Timer = $DespawnTimer
@onready var damage_hitbox: HitboxArea = $DamageHitbox
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D


func _ready() -> void:
	despawn_timer.start()
	damage_hitbox.sender = sender
	damage_hitbox.monitoring = true

	self.physics_material_override = PhysicsMaterial.new()
	self.physics_material_override.bounce = 1.0

	if pending_position:
		global_position = pending_position

	if pending_impulse and Utils.is_physics_owner(self):
		apply_central_impulse(pending_impulse)

	if not Utils.is_physics_owner(self):
		freeze = true


func _physics_process(delta: float) -> void:
	if despawn_timer.time_left < 1.0 and particles_stopped == false:
		particles_stopped = true
		gpu_particles_3d.emitting = false

	if self.get_contact_count() > 0 and can_bounce:
		despawn_timer.start(bounce_despawn_duration)
		can_bounce = false
		self.physics_material_override.bounce = 0.4
		self.physics_material_override.absorbent = true
		self.gravity_scale = 1.0
		immunity_left = sender_immunity_duration

	if not can_bounce and has_sender_immune:
		immunity_left -= delta
		if immunity_left <= 0.0:
			has_sender_immune = false


func set_sender(id: int) -> void:
	sender = id
	damage_hitbox.sender = id
	has_sender_immune = true
	immunity_left = 0.0


func reset_bounce() -> void:
	can_bounce = true
	has_sender_immune = true
	immunity_left = 0.0
	self.physics_material_override.bounce = 1.0
	self.physics_material_override.absorbent = false


func _on_despawn_timer_timeout() -> void:
	spawner.request_despawn(self)
