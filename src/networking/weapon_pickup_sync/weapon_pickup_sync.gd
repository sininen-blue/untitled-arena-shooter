class_name WeaponPickupSync
extends Node


func request_weapon(requester: Player, weapon_instance: HitscanWeapon) -> void:
	var weapon_path: String = weapon_instance.scene_file_path
	var ammo: int = weapon_instance.ammo
	
	give_weapon.rpc(requester.name, weapon_path, ammo)


@rpc("any_peer", "call_local", "reliable")
func give_weapon(target_name: String, weapon_path: String, ammo: int) -> void:
	var weapon_instance: HitscanWeapon = load(weapon_path).instantiate()
	weapon_instance.ammo = ammo
	
	var target: Player = Utils.find_player(target_name, get_parent())
	
	target.hand_marker.add_child(weapon_instance)
	target.current_weapon = weapon_instance


func request_remove_weapon(requester: Player) -> void:
	remove_weapon.rpc(requester.name)


@rpc("any_peer", "call_local", "reliable")
func remove_weapon(target_name: String) -> void:
	var target: Player = Utils.find_player(target_name, get_parent())
	
	target.hand_marker.remove_child(target.current_weapon)
