extends Node3D


@export var weapon: PackedScene
@export var multiplayer_synchronizer: MultiplayerSynchronizer
@export var interact_area: Interact
@export var collision_shape_3d: CollisionShape3D

@export var respawn_time: float = 3.0
@export var rotation_speed: float = 4
@export var weapon_tilt: float = 45
@export var weapon_visible: bool = false


var weapon_instance: HitscanWeapon = null


@onready var weapon_spawn_marker: Marker3D = $WeaponSpawnMarker
@onready var respawn_timer: Timer = $RespawnTimer


func _ready() -> void:
	respawn_timer.wait_time = respawn_time
	weapon_instance = weapon.instantiate()
	
	self.add_child(weapon_instance)
	
	weapon_visible = true
	weapon_instance.rotation_degrees.x = weapon_tilt
	weapon_instance.global_position = weapon_spawn_marker.global_position
	
	if multiplayer.is_server():
		weapon_visible = true


func _process(delta: float) -> void:
	if weapon_instance:
		weapon_instance.rotate_y(rotation_speed * delta)


@rpc("any_peer", "call_local", "reliable")
func _set_weapon_visible(new_val: bool) -> void:
	weapon_visible = new_val
	
	if weapon_instance:
		weapon_instance.visible = weapon_visible
		collision_shape_3d.disabled = !weapon_visible


func _on_interact_area_interacted(interactee: Player) -> void:
	if respawn_timer.is_stopped() == false:
		return
	
	var player_weapon_instance: HitscanWeapon = weapon.instantiate()
	
	if interactee.current_weapon:
		interactee.drop_weapon()
	interactee.get_weapon(player_weapon_instance)

	_set_weapon_visible.rpc(false)
	respawn_timer.start()


func _on_respawn_timer_timeout() -> void:
	_set_weapon_visible.rpc(true)
