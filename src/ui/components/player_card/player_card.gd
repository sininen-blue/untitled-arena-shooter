class_name PlayerCard
extends Panel


@export var ready_texture: Texture2D
@export var not_ready_texture: Texture2D

@export var player_id: int = 0
@export var player_name: String = "":
	set = _set_player_name
@export var is_ready: bool = false:
	set = _set_is_ready


@onready var label: Label = $HBoxContainer/Label
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect

var enter_tween: Tween
var removing: bool = false


func _ready() -> void:
	label.text = player_name
	if is_ready:
		texture_rect.texture = ready_texture
	else:
		texture_rect.texture = not_ready_texture
	
	self.offset_transform_enabled = true
	enter_tween = get_tree().create_tween()
	enter_tween.set_ease(Tween.EASE_OUT)
	enter_tween.set_trans(Tween.TRANS_BACK)
	
	enter_tween.tween_property(self, "offset_transform_rotation", randf_range(-0.2, 0.2), 0.3)
	enter_tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1.4, 1.4), 0.3)
	enter_tween.tween_property(self, "offset_transform_rotation", 0, 0.2)
	enter_tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.2)


func remove() -> void:
	if removing:
		return
	removing = true

	if enter_tween:
		enter_tween.kill()

	enter_tween = get_tree().create_tween()
	enter_tween.set_ease(Tween.EASE_OUT)
	enter_tween.set_trans(Tween.TRANS_BACK)
	enter_tween.tween_property(self, "offset_transform_rotation", randf_range(-0.2, 0.2), 0.3)
	enter_tween.parallel().tween_property(self, "offset_transform_scale", Vector2(1.4, 1.4), 0.3)
	enter_tween.tween_property(self, "offset_transform_rotation", 0, 0.2)
	enter_tween.parallel().tween_property(self, "offset_transform_scale", Vector2.ZERO, 0.2)
	enter_tween.tween_callback(queue_free)


func _set_player_name(new_text: String) -> void:
	player_name = new_text
	
	if label:
		label.text = player_name


func _set_is_ready(new_val: bool) -> void:
	is_ready = new_val
	
	if texture_rect:
		if is_ready:
			texture_rect.texture = ready_texture
		else:
			texture_rect.texture = not_ready_texture
