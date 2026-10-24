class_name  Player
extends CharacterBody3D


signal interacted(player: Player)
signal killed(by: int, player: Player)


@export_group("References")
@export var dropped_spawner: DroppedSpawner
@export var slipper_spawner: SlipperSpanwner
@export var pickup_handler: PickupHandler
@export var decal_spawner: DecalSpawner
@export var tracer_spawner: TracerSpawner
@export var jump_particle_spawner: JumpParticleSpawner
@export var land_particle_spawner: LandParticleSpawner
@export var damage_number_spawner: DamageNumberSpawner
@export var damage_handler: DamageHandler
@export var parry_handler: ParryHandler

@export_group("Camera")
@export var mouse_sensitivity: float = 0.1
@export var default_head_recoil_recovery: float = 3.0

@export_group("Other Stats")
@export var mass: float = 2.0
@export var weapon_throw_force: float = 8.0
@export var pitch_degrees: float = 0.0

@export_group("Slipper_related")
@export var slipper_throw_force: float = 12.0
@export var parry_force: float = 15.0
@export var max_slipper_ammo: int = 2
@export var current_slipper_ammo: int = 2

@export_group("States")
@export var locked: bool = false
@export var is_idle: bool = false
@export var is_walking: bool = false
@export var is_running: bool = false
@export var is_jumping: bool = false
@export var is_crouching: bool = false
@export var is_sliding: bool = false
@export var is_throwing: bool = false
@export var on_ground: bool = true
@export var on_air: bool = false
@export var wall_slide_side: int = 0

@export var has_weapon: bool = false
@export var has_handgun: bool = false
@export var has_longgun: bool = false

@export var wall_climb_state: State
@export var wall_slide_state: State

@export_group("Health and damage")
@export var damage_number_offset: Vector3 = Vector3(0.2, 0.6, 0)
@export var headshot_mult: float = 1.5
@export var max_health: float = 20
@export var health: float = max_health


var current_weapon: HitscanWeapon
var is_dead: bool = false

var twist_input: float = 0.0
var pitch_input: float = 0.0
var recoil_offset: float = 0.0

var input_direction: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var wish_velocity: Vector3 = Vector3.ZERO
var is_zoomed: bool = false


@onready var head: Node3D = %Head
@onready var head_target: Marker3D = $HeadTarget
@onready var camera: Camera3D = %Camera
@onready var hand_marker: Marker3D = %HandMarker


@onready var interact_cast: RayCast3D = %InteractCast
@onready var gun_cast: RayCast3D = %GunCast

@onready var hud: CanvasLayer = $Hud
@onready var shaders: CanvasLayer = $Shaders
@onready var settings_panel: SettingsPanel = %SettingsPanel

@onready var parry_cololdown_timer: Timer = %ParryCololdownTimer
@onready var parry_hurtbox: Area3D = %ParryHurtbox

@onready var health_bar: HealthBar = %HealthBar
@onready var crosshair: Crosshair = $Hud/Control/Crosshair
@onready var sniper_scope: ColorRect = %SniperScope

@onready var head_hurtbox: HurtboxArea = $HeadHurtbox
@onready var body_hurtbox: HurtboxArea = $BodyHurtbox

@onready var parry_effect: ParryEffect = $ParryEffect
@onready var run_particle: RunParticle = $RunParticle

@onready var jump_sound: AudioStreamPlayer3D = $Sounds/JumpSound
@onready var land_sound: AudioStreamPlayer3D = $Sounds/LandSound
@onready var hurt_sound: AudioStreamPlayer3D = $Sounds/HurtSound

@onready var player_model: PlayerModel = $PlayerModel


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if get_parent() != null: # NOTE: should replace these
		dropped_spawner = get_parent().dropped_spawner
		slipper_spawner = get_parent().slipper_spawner
		pickup_handler = get_parent().pickup_handler
		decal_spawner = get_parent().decal_spawner
		tracer_spawner = get_parent().tracer_spawner
		jump_particle_spawner = get_parent().jump_particle_spawner
		land_particle_spawner = get_parent().land_particle_spawner
		damage_number_spawner = get_parent().damage_number_spawner
		damage_handler = get_parent().damage_handler
		parry_handler = get_parent().parry_handler

	if Utils.is_remote(self):
		hud.visible = false
		shaders.visible = false
		return
	
	player_model.visible = false
	hud.visible = true
	shaders.visible = true
	health_bar.max_health = max_health

	camera.current = true
	mouse_sensitivity = Config.get_setting("sensitivity", mouse_sensitivity)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_multiplayer_authority() and get_parent() != null and get_parent().has_method("notify_player_spawned"):
		get_parent().notify_player_spawned()


func _combat_blocked() -> bool:
	return locked or is_dead


func _input(event: InputEvent) -> void:
	if Utils.is_remote(self):
		return
	
	if event.is_action_pressed("debug_take_damage") and not _combat_blocked():
		damage_handler.request_hit(name, 5.0)
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		settings_panel.visible = true

	if event.is_action_pressed("left_click") and settings_panel.visible == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if _combat_blocked():
		return
	
	if event.is_action_pressed("interact"):
		interacted.emit(self) # NOTE: remve move to collision required
		
		if interact_cast.is_colliding():
			var interactable := interact_cast.get_collider()
			interactable.interact(self)
		elif interact_cast.is_colliding() == false and current_weapon:
			drop_weapon()
	
	if event.is_action_pressed("throw") and current_slipper_ammo > 0 and not is_throwing:
		current_slipper_ammo -= 1
		is_throwing = true
		var throw_vec: Vector3 = -head.global_basis.z * slipper_throw_force
		slipper_spawner.request_spawn(self, hand_marker.global_position, throw_vec)
	
	if event.is_action_pressed("parry") and parry_cololdown_timer.is_stopped():
		parry_cololdown_timer.start(parry_effect.default_duration)
		play_parry_effect()
		parry_handler.request_parry(-head.global_basis.z)


func _unhandled_input(event: InputEvent) -> void:
	if Utils.is_remote(self):
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		twist_input -= event.screen_relative.x * mouse_sensitivity
		pitch_input -= event.screen_relative.y * mouse_sensitivity
		pitch_input = clampf(pitch_input, -85, 85)
		pitch_degrees = pitch_input


func _process(delta: float) -> void:
	align_gun_to_hand_look()
	if Utils.is_remote(self):
		return
	
	var tracer_ends: Array[Vector3] = []
	if not _combat_blocked() and Input.is_action_pressed("shoot") and current_weapon:
		if current_weapon.can_shoot():
			current_weapon.shoot()

			for i in current_weapon.projectiles:
				current_weapon.apply_spread(gun_cast, self.get_speed())
				gun_cast.force_raycast_update()

				if gun_cast.is_colliding():
					var hit := gun_cast.get_collision_point()
					tracer_ends.append(hit)

					if gun_cast.get_collider() is HurtboxArea:
						var hurtbox := gun_cast.get_collider() as HurtboxArea
						if hurtbox.get_parent() != self:
							hurtbox.take_hit(multiplayer.get_unique_id(), current_weapon.damage)
							crosshair.show_hitmarker()
					else:
						decal_spawner.request_spawn(gun_cast.get_collision_point(), gun_cast.get_collision_normal())
				else:
					tracer_ends.append(gun_cast.to_global(gun_cast.target_position))

			if recoil_offset < current_weapon.max_head_recoil:
				recoil_offset += current_weapon.head_recoil
		else:
			current_weapon.dry_fire()
			
	if current_weapon:
		current_weapon.apply_spread_recovery(gun_cast, delta)
		recoil_offset = Utils.exp_decay(recoil_offset, 0, current_weapon.head_recoil_recovery, delta)
	else:
		recoil_offset = Utils.exp_decay(recoil_offset, 0, default_head_recoil_recovery, delta)
	
	
	# NOTE: put this in a compenent
	if self.is_on_floor():
		wall_climb_state.time = 0
		wall_slide_state.time = 0
	
	var target_pitch := clampf(pitch_input + recoil_offset, -85.0, 85.0)
	head.basis = Basis(Quaternion(Vector3.RIGHT, deg_to_rad(target_pitch)))
	align_gun_to_hand_look()

	if not tracer_ends.is_empty() and current_weapon and current_weapon.muzzle:
		var muzzle_position := current_weapon.muzzle.get_global_transform_interpolated().origin
		for tracer_end in tracer_ends:
			tracer_spawner.request_spawn(muzzle_position, tracer_end)


func _physics_process(_delta: float) -> void:
	if Utils.is_remote(self):
		return

	basis = Basis(Quaternion(Vector3.UP, deg_to_rad(twist_input)))

	if locked:
		return
	
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (self.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	move_and_slide()
	on_ground = is_on_floor()
	on_air = not on_ground


func get_speed() -> float:
	return self.velocity.length()


func align_gun_to_hand_look() -> void:
	if not is_inside_tree() or player_model == null or hand_marker == null:
		return
	if not player_model.is_inside_tree() or not hand_marker.is_inside_tree():
		return

	var origin := player_model.get_right_hand_global_position()
	var target := player_model.get_hand_look_global_position()
	hand_marker.global_position = origin

	var to_target := target - origin
	if to_target.length_squared() < 0.0001:
		return
	if absf(to_target.normalized().dot(Vector3.UP)) > 0.999:
		return

	hand_marker.look_at(target, Vector3.UP)


func play_parry_effect() -> void:
	if multiplayer.multiplayer_peer == null:
		parry_effect.start(parry_effect.default_duration)
		return
	_play_parry_effect.rpc()


@rpc("authority", "call_local", "reliable")
func _play_parry_effect() -> void:
	parry_effect.start(parry_effect.default_duration)


func play_jump_sound() -> void:
	_play_movement_sound(jump_sound, _play_jump_sound)


func play_land_sound() -> void:
	_play_movement_sound(land_sound, _play_land_sound)


func _play_movement_sound(sound: AudioStreamPlayer3D, remote: Callable) -> void:
	if multiplayer.multiplayer_peer == null:
		sound.play()
		return
	remote.rpc()


@rpc("authority", "call_local", "unreliable")
func _play_jump_sound() -> void:
	jump_sound.play()


@rpc("authority", "call_local", "unreliable")
func _play_land_sound() -> void:
	land_sound.play()


func play_weapon_sound() -> void:
	if multiplayer.multiplayer_peer == null:
		_play_weapon_sound()
		return
	_play_weapon_sound.rpc()


@rpc("authority", "call_local", "unreliable")
func _play_weapon_sound() -> void:
	if is_instance_valid(current_weapon) and current_weapon.sound_player:
		current_weapon.sound_player.play()


func play_no_ammo_sound() -> void:
	if multiplayer.multiplayer_peer == null:
		_play_no_ammo_sound()
		return
	_play_no_ammo_sound.rpc()


@rpc("authority", "call_local", "unreliable")
func _play_no_ammo_sound() -> void:
	if is_instance_valid(current_weapon) and current_weapon.no_ammo_player:
		current_weapon.no_ammo_player.play()


func apply_host_state(hp: float, now_dead: bool) -> void:
	health = hp
	health_bar.current_health = health
	if now_dead and not is_dead:
		hurt_sound.play()
		is_dead = true
		locked = true
		visible = false
		position.y = -500
		_set_hurtboxes_active(false)
		killed.emit(0, self)
	elif not now_dead:
		is_dead = false
		visible = true
		_set_hurtboxes_active(true)


func _set_hurtboxes_active(active: bool) -> void:
	var layer := 4 if active else 0
	var mask := 8 if active else 0
	for hurtbox in [head_hurtbox, body_hurtbox]:
		hurtbox.collision_layer = layer
		hurtbox.collision_mask = mask
		hurtbox.monitoring = active
		hurtbox.monitorable = active


func get_weapon(weapon_instance: HitscanWeapon) -> void:
	pickup_handler.request_equip(name, weapon_instance.scene_file_path, int(weapon_instance.ammo))
	weapon_instance.queue_free()


func drop_weapon() -> void:
	if current_weapon == null or _combat_blocked():
		return
	var spawn_loc: Vector3 = hand_marker.global_position
	var throw_direction: Vector3 = (-global_basis.z + Vector3.UP).normalized()
	var throw_rotation: float = atan2(-global_basis.z.x, -global_basis.z.z)
	pickup_handler.request_drop(
		int(current_weapon.ammo),
		spawn_loc,
		throw_direction,
		throw_rotation
	)


func remove_weapon() -> void:
	pickup_handler.request_remove_weapon(self)


func _on_head_hurtbox_hit(_hitter_id: int, damage: float, source: Area3D = null) -> void:
	var dealt: float
	if source == null:
		dealt = damage * headshot_mult
		damage_handler.request_hit(name, dealt)
		damage_number_spawner.request_spawn(head.global_position + damage_number_offset, dealt)
		return
	if not multiplayer.is_server() or _sender_grace_blocks(source):
		return
	dealt = damage * headshot_mult
	damage_handler.apply_server_hit(name, dealt)
	damage_number_spawner.request_spawn(head.global_position + damage_number_offset, dealt)


func _on_body_hurtbox_hit(_hitter_id: int, damage: float, source: Area3D = null) -> void:
	if source == null:
		damage_handler.request_hit(name, damage)
		damage_number_spawner.request_spawn(head.global_position + damage_number_offset, damage)
		return
	if not multiplayer.is_server() or _sender_grace_blocks(source):
		return
	damage_handler.apply_server_hit(name, damage)
	damage_number_spawner.request_spawn(head.global_position + damage_number_offset, damage)


func _sender_grace_blocks(source: Area3D) -> bool:
	if source == null:
		return false
	var slipper := source.get_parent() as Slipper

	if slipper != null:
		if slipper.has_sender_immune and slipper.sender == int(name):
			return true
	
	return false


func _on_settings_panel_resumed() -> void:
	settings_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	mouse_sensitivity = Config.get_setting("sensitivity", mouse_sensitivity)
