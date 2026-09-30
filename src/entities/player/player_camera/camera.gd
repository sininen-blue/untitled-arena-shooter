extends Camera3D


@export var player: Player
@export var state_machine: StateMachine

@export var max_camera_tilt: float = 1.0
@export var camera_tilt_weight: float = 8.0

@export var slide_tilt: float = -5.0
@export var slide_weight: float = 15.0


func _process(delta: float) -> void:
	match state_machine.current_state.name:
		"Slide":
			var local_velocity := player.global_transform.basis.inverse() * player.velocity
			if local_velocity.x > 0:
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, slide_tilt, slide_weight, delta)
			else:
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, -slide_tilt, slide_weight, delta)
		_:
			if player.input_direction.x == 0:
				self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, 0, camera_tilt_weight, delta)
			else:
				if player.input_direction.x < 0:
					self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, max_camera_tilt, camera_tilt_weight, delta)
				else:
					self.rotation_degrees.z = Utils.exp_decay(self.rotation_degrees.z, -max_camera_tilt, camera_tilt_weight, delta)
