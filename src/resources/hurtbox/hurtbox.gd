class_name HurtboxArea
extends Area3D


signal hit(hitter: int, damage: float)


func _on_area_entered(area: Area3D) -> void:
	var hitter: int = area.sender
	var damage: float = area.damage
	
	hit.emit(hitter, damage)


func take_hit(hitter: int, damage: float) -> void:
	hit.emit(hitter, damage)
