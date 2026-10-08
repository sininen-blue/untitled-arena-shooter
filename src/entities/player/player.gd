class_name  Player
extends CharacterBody3D


signal interacted(player: Player)
signal killed(by: int, player: Player)


@export var dropped_spawner: DroppedSpawner
@export var slipper_spawner: SlipperSpanwner
@export var weapon_pickup_sync: WeaponPickupSync
@export var decal_spawner: DecalSpawner

@export var mouse_sensitivity: float = 0.1
@export var default_head_recoil_recovery: float = 3.0

@export var locked: bool = false

@export var mass: float = 2.0
@export var weapon_throw_force: float = 8.0

@export var slipper_throw_force: float = 12.0
@export var parry_force: float = 15.0
@export var max_slipper_ammo: int = 2

@export var wall_climb_state: State
@export var wall_slide_state: State

@export var headshot_mult: float = 1.5
@export var max_health: float = 20
@export var health: float = max_health


var current_weapon: HitscanWeapon
var current_slipper_ammo: int = max_slipper_ammo

var twist_input: float = 0.0
var pitch_input: float = 0.0
var recoil_offset: float = 0.0

var input_direction: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var wish_velocity: Vector3 = Vector3.ZERO


@onready var head: Node3D = %Head
@onready var head_target: Marker3D = $HeadTarget
@onready var camera: Camera3D = %Camera
@onready var hand_marker: Marker3D = %HandMarker


@onready var interact_cast: RayCast3D = %InteractCast
@onready var gun_cast: RayCast3D = %GunCast

@onready var parry_cololdown_timer: Timer = %ParryCololdownTimer
@onready var parry_hurtbox: Area3D = %ParryHurtbox


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	if get_parent() != null: # NOTE: should replace these
		dropped_spawner = get_parent().dropped_spawner
		slipper_spawner = get_parent().slipper_spawner
		weapon_pickup_sync = get_parent().weapon_pickup_sync
		decal_spawner = get_parent().decal_spawner
	
	
	camera.current = true


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("interact"):
		interacted.emit(self) # NOTE: remve move to collision required
		
		if interact_cast.is_colliding():
			var interactable := interact_cast.get_collider()
			interactable.interact(self)
		elif interact_cast.is_colliding() == false and current_weapon:
			drop_weapon()
	
	if event.is_action_pressed("throw") and current_slipper_ammo > 0:
		var throw_vec: Vector3 = -head.global_basis.z * slipper_throw_force
		slipper_spawner.request_spawn(self, hand_marker.global_position, throw_vec)
	
	if event.is_action_pressed("parry") and parry_cololdown_timer.is_stopped():
		parry_cololdown_timer.start()
		
		if parry_hurtbox.has_overlapping_areas():
			var slipper_hitboxes: Array[Area3D] = parry_hurtbox.get_overlapping_areas()
			var slippers: Array[Slipper] = []
			for hitbox: Area3D in slipper_hitboxes:
				slippers.append(hitbox.get_parent())
			
			slippers.sort_custom(func(a, b): 
				return (
					head.global_position.distance_squared_to(a.global_position) >
					head.global_position.distance_squared_to(b.global_position)
					)
				)
			
			var closest: Slipper = slippers.pop_front()
			closest.reset_bounce()
			closest.global_position = hand_marker.global_position
			closest.apply_central_impulse(-head.global_basis.z * slipper_throw_force*2)
			
			self.velocity += head.global_basis.z * parry_force
			
			for slipper: Slipper in slippers:
				slipper.reset_bounce()
				var dir: Vector3 = head.global_position.direction_to(slipper.global_position)
				slipper.apply_central_impulse(dir * slipper_throw_force/2)


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		twist_input -= event.screen_relative.x * mouse_sensitivity
		pitch_input -= event.screen_relative.y * mouse_sensitivity
		pitch_input = clampf(pitch_input, -85, 85)


func _process(delta: float) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	
	if Input.is_action_pressed("shoot") and current_weapon:
		if current_weapon.can_shoot():
			current_weapon.shoot()
			current_weapon.apply_spread(gun_cast, self.get_speed())
			gun_cast.force_raycast_update()
			
			if recoil_offset < current_weapon.max_head_recoil:
				recoil_offset += current_weapon.head_recoil
			
			if gun_cast.is_colliding():
				if gun_cast.get_collider() is HurtboxArea:
					pass
				else:
					decal_spawner.request_spawn(gun_cast.get_collision_point())
	
	if current_weapon:
		current_weapon.apply_spread_recovery(gun_cast, delta)
		recoil_offset = Utils.exp_decay(recoil_offset, 0, current_weapon.head_recoil_recovery, delta)
	else:
		recoil_offset = Utils.exp_decay(recoil_offset, 0, default_head_recoil_recovery, delta)
	
	
	# NOTE: put this in a compenent
	if self.is_on_floor():
		wall_climb_state.time = 0
		wall_slide_state.time = 0
	
	var twist_q = Quaternion(Vector3.UP, deg_to_rad(twist_input))
	var body_current_q = basis.get_rotation_quaternion()
	var smoothed_body_q = body_current_q.slerp(twist_q, delta * 40.0)
	basis = Basis(smoothed_body_q)
	
	var target_pitch = clampf(pitch_input + recoil_offset, -85.0, 85.0)
	var pitch_q = Quaternion(Vector3.RIGHT, deg_to_rad(target_pitch))
	var current_head_q = head.basis.get_rotation_quaternion()
	var smoothed_head_q = current_head_q.slerp(pitch_q, delta * 40.0)
	head.basis = Basis(smoothed_head_q)


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return
	
	if locked:
		return
	
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (self.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	move_and_slide()


func get_speed() -> float:
	return self.velocity.length()


@rpc("any_peer", "call_local", "reliable") # this feels bad but i'll keep it for now
func take_damage(hitter_id: int, damage: float) -> void:
	health -= damage
	if health <= 0:
		self.visible = false
		killed.emit(hitter_id, self)


func get_weapon(weapon_instance: HitscanWeapon) -> void:
	weapon_pickup_sync.request_weapon(self, weapon_instance)


func drop_weapon() -> void:
	if current_weapon:
		var weapon: HitscanWeapon = current_weapon.duplicate()
		var spawn_loc: Vector3 = hand_marker.global_position
		var throw_direction: Vector3 = (-global_basis.z + Vector3.UP).normalized()
		var throw_rotation: float = atan2(-global_basis.z.x, -global_basis.z.z)
		dropped_spawner.request_spawn(weapon, spawn_loc, throw_direction, throw_rotation)

		weapon_pickup_sync.request_remove_weapon(self)
		current_weapon = null


func remove_weapon() -> void:
	weapon_pickup_sync.request_remove_weapon(self)
	current_weapon = null


# hitter can either be a node or an int
func _on_head_hurtbox_hit(hitter_id: int, damage: float) -> void:
	take_damage.rpc(hitter_id, damage * headshot_mult)


func _on_body_hurtbox_hit(hitter_id: int, damage: float) -> void:
	take_damage.rpc(hitter_id, damage * headshot_mult)
