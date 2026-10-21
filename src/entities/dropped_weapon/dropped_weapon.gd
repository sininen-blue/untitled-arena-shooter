class_name DroppedWeapon
extends RigidBody3D


@export var spawner: DroppedSpawner

var weapon_file_path: String
var weapon_ammo: int
var weapon_instance: HitscanWeapon

var pending_impulse: Vector3 = Vector3.ZERO
var pending_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	weapon_instance = load(weapon_file_path).instantiate()
	weapon_instance.ammo = weapon_ammo
	add_child(weapon_instance)

	if pending_position != Vector3.ZERO:
		self.global_position = pending_position

	if pending_impulse != Vector3.ZERO and Utils.is_physics_owner(self):
		apply_central_impulse(pending_impulse)

	if not Utils.is_physics_owner(self):
		freeze = true


func _on_interact_area_interacted(interactee: Player) -> void:
	if not interactee.is_multiplayer_authority():
		return

	if interactee.locked or interactee.is_dead:
		return

	if interactee.current_weapon != null:
		interactee.drop_weapon()

	spawner.request_dropped_pickup(name)


func _on_despawn_timer_timeout() -> void:
	spawner.request_despawn(self)
