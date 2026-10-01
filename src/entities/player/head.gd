extends Node3D


@export var state_machine: StateMachine
@export var head_target: Marker3D

@export var default_head_pos: float = 1.0
@export var follow_strenght: float = 8.0

@export_group("landing")
@export var landing_duration: float = 0.2
@export var max_landing_force: float = -15.0
@export var min_landing_pos: float = 0.8
@export var max_landing_pos: float = 0.4
@export var landing_pos_curve: Curve


func _process(delta: float) -> void:
	self.position = Utils.exp_decay(self.position, head_target.position, follow_strenght, delta)


func _on_air_air_to_ground(force: float) -> void:
	var sample_point: float = force/max_landing_force
	var head_weight: float = landing_pos_curve.sample(sample_point)
	
	head_target.position.y = min_landing_pos + (max_landing_pos - min_landing_pos) * head_weight
	await get_tree().create_timer(landing_duration).timeout
	
	if state_machine.current_state.is_in_group("slide") == false:
		head_target.position.y = default_head_pos
