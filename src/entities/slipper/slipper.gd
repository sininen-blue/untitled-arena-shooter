class_name Slipper
extends RigidBody3D


@export var sender_immunity_duration: float = 0.2
@export var bounce_despawn_duration: float = 2.0
@export var spawner: SlipperSpanwner


var sender: int
var pending_position: Vector3
var pending_impulse: Vector3

var can_bounce: bool = true


@onready var despawn_timer: Timer = $DespawnTimer
@onready var damage_hitbox: HitboxArea = $DamageHitbox


func _ready() -> void:
	despawn_timer.start()
	damage_hitbox.sender = sender
	
	self.physics_material_override = PhysicsMaterial.new()
	self.physics_material_override.bounce = 1.0
	
	if pending_position:
		global_position = pending_position

	if pending_impulse:
		apply_central_impulse(pending_impulse)


func _physics_process(_delta: float) -> void:
	if self.get_contact_count() > 0 and can_bounce:
		despawn_timer.start(bounce_despawn_duration)
		can_bounce = false
		self.physics_material_override.bounce = 0.4
		self.physics_material_override.absorbent = true


func reset_bounce() -> void:
	can_bounce = true
	self.physics_material_override.bounce = 1.0
	self.physics_material_override.absorbent = false


func _on_despawn_timer_timeout() -> void:
	spawner.request_despawn(self)
