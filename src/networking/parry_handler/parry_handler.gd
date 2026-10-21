class_name ParryHandler
extends Node


@export var main: Node


func request_parry(aim: Vector3) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	_request_parry.rpc_id(1, aim)


@rpc("any_peer", "call_local", "reliable")
func _request_parry(aim: Vector3) -> void:
	if not multiplayer.is_server() or not main.is_combat_live():
		return
	var id := Utils.sender_id(self)
	if main.damage_handler.is_dead(id):
		return
	var player := Utils.find_player(str(id), main)
	if player == null:
		return
	_resolve_parry(player, aim)


func _resolve_parry(player: Player, aim: Vector3) -> void:
	var aim_dir := aim.normalized() if aim.length_squared() > 0.0001 else -player.head.global_basis.z
	var slippers: Array[Slipper] = []
	for area: Area3D in player.parry_hurtbox.get_overlapping_areas():
		var slipper := area.get_parent() as Slipper
		if slipper:
			slippers.append(slipper)
	if slippers.is_empty():
		return
	slippers.sort_custom(func(a: Slipper, b: Slipper) -> bool:
		return player.head.global_position.distance_squared_to(a.global_position) < player.head.global_position.distance_squared_to(b.global_position)
	)
	var closest: Slipper = slippers.pop_front()
	_redirect_slipper(closest, player, aim_dir, player.slipper_throw_force * 2.0)
	_apply_knockback.rpc_id(player.get_multiplayer_authority(), player.name, -aim_dir * player.parry_force)
	for slipper: Slipper in slippers:
		var dir := player.head.global_position.direction_to(slipper.global_position)
		_redirect_slipper(slipper, player, dir, player.slipper_throw_force * 0.5)


func _redirect_slipper(slipper: Slipper, player: Player, direction: Vector3, force: float) -> void:
	slipper.set_sender(int(player.name))
	slipper.reset_bounce()
	if force >= player.slipper_throw_force:
		slipper.global_position = player.hand_marker.global_position
	slipper.apply_central_impulse(direction * force)


@rpc("authority", "call_local", "reliable")
func _apply_knockback(player_name: String, impulse: Vector3) -> void:
	var player := Utils.find_player(player_name, main)
	if player and player.is_multiplayer_authority():
		player.velocity += impulse
