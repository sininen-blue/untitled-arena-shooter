extends Node3D


@export var weapon: PackedScene
@export var rotation_speed: float = 4
@export var weapon_tilt: float = 15


var weapon_instance: HitscanWeapon = null


@onready var weapon_spawn_marker: Marker3D = $WeaponSpawnMarker


func _ready() -> void:
	weapon_instance = weapon.instantiate()
	
	self.add_child(weapon_instance)
	
	weapon_instance.rotate_x(weapon_tilt)
	weapon_instance.global_position = weapon_spawn_marker.global_position


func _process(delta: float) -> void:
	if weapon_instance:
		weapon_instance.rotate_y(rotation_speed * delta)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.interacted.connect(_on_player_interacted)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		body.interacted.disconnect(_on_player_interacted)


func _on_player_interacted(player: Player) -> void:
	var player_weaopn_instance: HitscanWeapon = weapon.instantiate()
	player.get_weapon(player_weaopn_instance)

	remove_child(weapon_instance)
