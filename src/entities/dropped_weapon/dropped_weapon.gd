class_name DroppedWeapon
extends RigidBody3D


@export var spawner: DroppedSpawner
@export var weapon_scene: PackedScene 
@export var weapon_instance: HitscanWeapon


func _ready() -> void:
	if weapon_instance == null:
		weapon_instance = weapon_scene.instantiate()
	self.add_child(weapon_instance)


func _on_interact_area_interacted(interactee: Player) -> void:
	var local_weapon_instance: HitscanWeapon = weapon_instance.duplicate()
	
	if interactee.current_weapon != null:
		interactee.drop_weapon()
	
	interactee.get_weapon(local_weapon_instance)
	spawner.request_despawn(self)
