class_name State
extends Node

var state_machine: StateMachine = null


func enter() -> void:
	pass


func exit(_new_state: State) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
