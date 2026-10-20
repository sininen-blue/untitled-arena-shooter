extends HitscanWeapon


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_shot() -> void:
	animation_player.play("pull_back")
