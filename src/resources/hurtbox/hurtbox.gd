class_name HurtboxArea
extends Area3D


signal hit(damage: float, source: Area3D)


func _on_area_entered(area: Area3D) -> void:
	hit.emit(area.damage, area)


func take_hit(damage: float) -> void:
	hit.emit(damage, null)
