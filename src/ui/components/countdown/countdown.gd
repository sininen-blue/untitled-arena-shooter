class_name Countdown
extends Control


signal finished()


@export var default_start_number: float = 5
@export var scale_curve: Curve
@export var max_scale: float = 2
@export var min_scale: float = 1
@export var end_text: String = "GO!"


@export var debug: bool = false


var current_number: float = 0
var max_number: float = 0


@onready var label: Label = $Label
@onready var timer: Timer = $Timer


func _ready() -> void:
	label.offset_transform_enabled = true
	self.visible = false

	if debug:
		start()


func start(start_number: float = default_start_number) -> void:
	self.visible = true
	current_number = start_number
	max_number = start_number

	label.text = str(int(current_number))
	timer.start(1)


func stop() -> void:
	timer.stop()


func _on_timer_timeout() -> void:
	current_number -= 1

	var tween: Tween = get_tree().create_tween()
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(tween.TRANS_BACK)

	if current_number > 0:
		var sample_point: float = current_number/max_number
		var offset_scale: float = min_scale + ((max_scale - min_scale) * scale_curve.sample(sample_point))

		tween.tween_property(label, "offset_transform_scale", Vector2(offset_scale, offset_scale), 0.2)
		tween.parallel().tween_property(label, "offset_transform_rotation", 0.2, 0.2)

		label.text = str(int(current_number))

		tween.tween_property(label, "offset_transform_scale", Vector2(offset_scale-0.5, offset_scale-0.5), 0.2)
		tween.parallel().tween_property(label, "offset_transform_rotation", 0, 0.2)
		
		timer.start(1)
	else:
		tween.tween_property(label, "offset_transform_scale", Vector2(1.5, 1.5), 0.4)
		tween.parallel().tween_property(label, "offset_transform_rotation", 0.2, 0.4)
		label.text = end_text
		tween.tween_property(label, "offset_transform_scale", Vector2(0, 0), 1)
		
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(label, "offset_transform_rotation", -20, 1)
		tween.tween_property(label, "visible", false, 0.1)
		
		await tween.finished
		finished.emit()
