extends CanvasLayer

signal loading_screen_ready()


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()


func _on_scene_loader_progress_changed(_progress: float) -> void:
	pass


func _on_scene_loader_load_finished() -> void:
	animation_player.play_backwards("transistion")
	await animation_player.animation_finished
	self.queue_free()
