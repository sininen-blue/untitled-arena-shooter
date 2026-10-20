extends Camera3D


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


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		return

	if event.is_action_pressed("zoom_in"):
		is_zoomed = true
		_tween_zoom(zoom_fov)
	if event.is_action_released("zoom_in"):
		is_zoomed = false
		_tween_zoom(target_fov)


func _process(delta: float) -> void:
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
