@tool
extends Node3D


@export_tool_button("Snap to Collision Below", "ArrowDown") var snap_to_collision_below: Callable = snap_to_closest_collision_down

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
	if Engine.is_editor_hint():
		return

	respawn_timer.wait_time = respawn_time
	weapon_instance = weapon.instantiate()
	
	self.add_child(weapon_instance)
	
	weapon_visible = true
	weapon_instance.rotation_degrees.x = weapon_tilt
	weapon_instance.global_position = weapon_spawn_marker.global_position
	
	if multiplayer.is_server():
		weapon_visible = true


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or weapon_instance == null:
		return

	weapon_instance.rotate_y(rotation_speed * delta)


func snap_to_closest_collision_down() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return

	var world := get_world_3d()
	if world == null or world.direct_space_state == null:
		push_warning("WeaponPickup: physics space is not available.")
		return

	var from := global_position + Vector3.UP * 0.01
	var query := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 1000.0)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = _own_collision_rids()

	var hit := world.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		push_warning("WeaponPickup: no collision found below.")
		return

	_set_global_position_with_undo(hit.position)


func _own_collision_rids() -> Array[RID]:
	var exclude: Array[RID] = []
	for node in find_children("*", "CollisionObject3D", true, false):
		exclude.append(node.get_rid())
	return exclude


func _set_global_position_with_undo(next_position: Vector3) -> void:
	if not Engine.has_singleton("EditorInterface"):
		global_position = next_position
		return

	var undo_redo = Engine.get_singleton("EditorInterface").call("get_editor_undo_redo")
	undo_redo.create_action("Snap Weapon Pickup to Collision Below")
	undo_redo.add_do_method(self, "set_global_position", next_position)
	undo_redo.add_undo_method(self, "set_global_position", global_position)
	undo_redo.commit_action()


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
