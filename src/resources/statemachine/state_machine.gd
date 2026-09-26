class_name StateMachine
extends Node

signal state_changed(state: State)

@export var initial_state: State

var current_state: State
var previous_state: State

var states: Dictionary = { }
var state_components: Dictionary = { }


func _ready() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is State:
			states[child] = child
			child.state_machine = self

	if initial_state:
		change_state(initial_state)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func change_state(new_state: State) -> void:
	if new_state.can_enter() == false:
		return
	
	if current_state:
		previous_state = current_state
		current_state.exit()

	current_state = states.get(new_state)

	if current_state:
		state_changed.emit(current_state)
		current_state.enter()


func get_current_state_name() -> String:
	if current_state:
		return current_state.name
	return "unavailable"


func get_previous_state_name() -> String:
	if previous_state:
		return previous_state.name
	return "unavailable"
