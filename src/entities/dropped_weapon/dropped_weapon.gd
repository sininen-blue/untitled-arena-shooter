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

	if pending_impulse != Vector3.ZERO:
		apply_central_impulse(pending_impulse)
	
	if pending_position != Vector3.ZERO:
		self.global_position = pending_position

func _on_interact_area_interacted(interactee: Player) -> void:
	var local_weapon_instance: HitscanWeapon = weapon_instance.duplicate()
	
	if interactee.current_weapon != null:
		interactee.drop_weapon()
	
	interactee.get_weapon(local_weapon_instance)
	spawner.request_despawn(self)
