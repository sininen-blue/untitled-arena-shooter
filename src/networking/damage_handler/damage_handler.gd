class_name DamageHandler
extends Node


@export var main: Node
@export var pickup_handler: PickupHandler


signal player_died(id: int)


var healths: Dictionary[int, float] = {}
var dead: Dictionary[int, bool] = {}




func is_dead(id: int) -> bool:
	return dead.get(id, false)


func reset_tables(players: Array) -> void:
	for player: Player in players:
		var id: int = int(player.name)
		healths[id] = player.max_health
		dead[id] = false


func replicate_state(player_name: String, hp: float, now_dead: bool) -> void:
	_apply_player_state.rpc(player_name, hp, now_dead)


func request_hit(victim_name: String, damage: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	_request_hit.rpc_id(1, victim_name, damage)


func apply_server_hit(victim_name: String, damage: float) -> void:
	if not multiplayer.is_server():
		return
	_apply_damage(victim_name, damage)


@rpc("any_peer", "call_local", "reliable")
func _request_hit(victim_name: String, damage: float) -> void:
	if not multiplayer.is_server():
		return

	var shooter_id: int = Utils.sender_id(self)
	if dead.get(shooter_id, false):
		return

	_apply_damage(victim_name, damage)


func _apply_damage(victim_name: String, damage: float) -> void:
	if not is_finite(damage) or damage < 0.0:
		return

	var victim_id := victim_name.to_int()
	if dead.get(victim_id, false):
		return

	if not NetworkManager.players.has(victim_id):
		return

	var player := Utils.find_player(victim_name, main)

	var max_health: float = 20.0
	if player:
		max_health = player.max_health

	var damaged: float = float(healths.get(victim_id, max_health)) - damage

	healths[victim_id] = damaged
	var now_dead: bool = damaged <= 0.0

	if now_dead:
		dead[victim_id] = true
		pickup_handler.clear_player(victim_name)
		player_died.emit(victim_id)

	_apply_player_state.rpc(victim_name, damaged, now_dead)


@rpc("authority", "call_local", "reliable")
func _apply_player_state(player_name: String, hp: float, now_dead: bool) -> void:
	var player := Utils.find_player(player_name, get_parent())
	if player:
		player.apply_host_state(hp, now_dead)
