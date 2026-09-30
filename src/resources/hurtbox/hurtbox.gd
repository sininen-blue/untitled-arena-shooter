class_name HurtboxArea
extends Area3D


signal hit(hitter: Node, damage: float)


func _on_area_entered(area: Area3D) -> void:
	var hitter: Node = area.sender
	var damage: float = area.damage
	
	hit.emit(hitter, damage)


func take_hit(hitter: Node, damage: float) -> void:
	hit.emit(hitter, damage)
