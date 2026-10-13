class_name HealthBar
extends TextureProgressBar

@export var max_health: float = 200:
	set = _set_max_health


var current_health: float = 0:
	set = _set_health
var value_tween: Tween
var damage_tween: Tween


func _ready() -> void:
	self.offset_transform_enabled = true


func _set_max_health(new_max_health: float) -> void:
	max_health = new_max_health
	self.max_value = max_health



func _set_health(new_health: float) -> void:
	current_health = clampf(new_health, 0, max_health)

	if not self.is_inside_tree():
		self.value = current_health
		return

	tween_damamge()
	tween_value()



func tween_value() -> void:
	if value_tween and value_tween.is_valid():
		value_tween.kill()

	value_tween = create_tween()
	value_tween.set_ease(Tween.EASE_OUT)
	value_tween.set_trans(Tween.TRANS_BACK)

	value_tween.tween_property(self, "value", current_health, 0.4)


func tween_damamge() -> void:
	if damage_tween and damage_tween.is_valid():
		damage_tween.kill()

	damage_tween = create_tween()
	damage_tween.set_ease(Tween.EASE_OUT)
	damage_tween.set_trans(Tween.TRANS_BACK)

	damage_tween.tween_property(self, "offset_transform_scale", Vector2(1.1, 1.1), 0.2)
	damage_tween.parallel().tween_property(self, "offset_transform_rotation", deg_to_rad(-6), 0.2)

	damage_tween.tween_property(self, "offset_transform_scale", Vector2(1.0, 1.0), 0.2)
	damage_tween.parallel().tween_property(self, "offset_transform_rotation", deg_to_rad(0), 0.2)
