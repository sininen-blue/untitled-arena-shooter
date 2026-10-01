extends CanvasLayer


@export var player: Player

@export_group("speed lines")
@export var min_speed: float = 5.0
@export var max_speed: float = 15.0
@export var lines_curve: Curve
@export var min_alpha: float = 0.0
@export var max_alpha: float = 1.0


var time: float = 0

@onready var speed_lines: ColorRect = $Control/SpeedLines


func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_method(func(v): 
		speed_lines.material.set_shader_parameter("sample_radius", v), 0.5, 0.8, 3.0)
	tween.tween_method(func(v): 
		speed_lines.material.set_shader_parameter("sample_radius", v), 0.8, 0.5, 3.0)


func _process(_delta: float) -> void:
	
	if player.velocity.length() < min_speed:
		speed_lines.material.set_shader_parameter("transparency", 0)
	else:
		var speed: float = clampf(player.velocity.length(), min_speed, max_speed)
		var sample_point: float = speed / max_speed
		var speed_weight: float = lines_curve.sample_baked(sample_point)
		var alpha = min_alpha + (max_alpha - min_alpha) * speed_weight
		
		speed_lines.material.set_shader_parameter("transparency", alpha)
