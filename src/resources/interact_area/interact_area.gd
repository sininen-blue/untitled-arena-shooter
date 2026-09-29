class_name Interact
extends Area3D


signal interacted(interactee: Player)


func interact(interactee: Player) -> void:
	interacted.emit(interactee)
