class_name DamageNumberParticle
extends Label3D


signal finished


@export var damage: float = 0
@export var speed: float = 0.2
@export var duration: float = 0.75
@export var shrink_time: float = 0.2
@export var spawner: DamageNumberSpawner


var time: float = 0
var finishing: bool = false
var pending_position: Vector3
var pending_damage: float


func _ready() -> void:
	if not finished.is_connected(_on_finished):
		finished.connect(_on_finished)

	if pending_position:
		global_position = pending_position
	if pending_damage:
		damage = pending_damage

	self.text = "-" + str(roundi(damage))


func _process(delta: float) -> void:
	time += delta
	position.y += speed * delta

	if time > duration:
		_finish()


func _finish() -> void:
	if finishing:
		return

	finishing = true
	set_process(false)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector3.ZERO, shrink_time)
	await tween.finished
	finished.emit()


func _on_finished() -> void:
	if spawner:
		spawner.request_despawn(self)
