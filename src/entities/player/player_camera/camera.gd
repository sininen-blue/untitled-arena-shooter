extends Camera3D


const TEST_RIFLE := preload("res://src/entities/weapons/test_weapon/test_rifle.gd")


@export var player: Player
@export var state_machine: StateMachine
@export var wall_raycasts: WallRaycasts

@export var max_camera_tilt: float = 1.0
@export var camera_tilt_weight: float = 8.0


@export_group("fov")
@export var max_speed: float = 15
@export var min_speed: float = 0.0
@export var max_fov: float = 90.0 # TODO: make this be relative to the base fov, also make muzzle effects per gun
@export var min_fov: float = 75.0
@export var fov_curve: Curve
@export var fov_weight: float = 4.0
@export var zoom_fov: float = 40.0
@export var zoom_time: float = 0.12


@export_group("slide")
@export var slide_tilt: float = -5.0
@export var slide_weight: float = 15.0


@export_group("wall slide")
@export var wall_slide_tilt: float = 15.0
@export var wall_slide_weight: float = 4.0


var target_fov: float = 0.0
var is_zoomed: bool = false
var zoom_tween: Tween
var shot_weapon: HitscanWeapon


@onready var sniper_scope: ColorRect = %SniperScope


func _ready() -> void:
	sniper_scope.visible = false
	_bind_weapon_shot()


func _input(event: InputEvent) -> void:
	if Utils.is_remote(self):
		return

	if event.is_action_pressed("zoom_in"):
		is_zoomed = true
		player.is_zoomed = true
		sniper_scope.visible = _has_test_rifle()
		_tween_zoom(zoom_fov)
	if event.is_action_released("zoom_in") and is_zoomed:
		_exit_zoom()


func _process(delta: float) -> void:
	_bind_weapon_shot()
	if is_zoomed and is_instance_valid(player.current_weapon) and player.current_weapon.recoil_pending:
		_exit_zoom()

	if is_zoomed:
		sniper_scope.visible = _has_test_rifle()

	var speed: float = clampf(player.velocity.length(), 0, max_speed)
	var sample_point: float = speed / max_speed
	var speed_weight: float = fov_curve.sample_baked(sample_point)
	target_fov = min_fov + (max_fov - min_fov) * speed_weight
	var zoom_owns_fov := is_zoomed or (zoom_tween and zoom_tween.is_running())
	if not zoom_owns_fov:
		self.fov = Utils.exp_decay(self.fov, target_fov, fov_weight, delta)

	
	match state_machine.current_state.name:
		"Slide":
			var local_velocity := player.global_transform.basis.inverse() * player.velocity
			if local_velocity.x > 0:
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, slide_tilt, slide_weight, delta)
			else:
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, -slide_tilt, slide_weight, delta)
		"WallSlide":
			if wall_raycasts.left_is_colliding():
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, -wall_slide_tilt, wall_slide_weight, delta)
			if wall_raycasts.right_is_colliding():
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, wall_slide_tilt, wall_slide_weight, delta)
		_:
			if player.input_direction.x == 0:
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, 0, camera_tilt_weight, delta)
			else:
				if player.input_direction.x < 0:
					self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, max_camera_tilt, camera_tilt_weight, delta)
				else:
					self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, -max_camera_tilt, camera_tilt_weight, delta)


func _tween_zoom(fov_value: float) -> void:
	if zoom_tween:
		zoom_tween.kill()
	zoom_tween = create_tween()
	zoom_tween.tween_property(self, "fov", fov_value, zoom_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _has_test_rifle() -> bool:
	var weapon := player.current_weapon
	return is_instance_valid(weapon) and weapon.get_script() == TEST_RIFLE


func _bind_weapon_shot() -> void:
	var weapon: HitscanWeapon = player.current_weapon if is_instance_valid(player.current_weapon) else null
	if weapon == shot_weapon:
		return

	if is_instance_valid(shot_weapon) and shot_weapon.shot.is_connected(_on_weapon_shot):
		shot_weapon.shot.disconnect(_on_weapon_shot)

	shot_weapon = weapon
	if shot_weapon:
		shot_weapon.shot.connect(_on_weapon_shot)


func _on_weapon_shot() -> void:
	if is_zoomed or (sniper_scope and sniper_scope.visible):
		_exit_zoom()


func _exit_zoom() -> void:
	is_zoomed = false
	player.is_zoomed = false
	sniper_scope.visible = false
	_tween_zoom(target_fov)
