extends Node3D


@export var head_target: Marker3D

@export var follow_strenght: float = 8.0


func _process(delta: float) -> void:
	self.position = Utils.exp_decay(self.position, head_target.position, follow_strenght, delta)
