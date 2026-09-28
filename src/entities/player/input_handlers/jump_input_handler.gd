extends Node


@export var player: Player
@export var is_jumping: bool = false

@export var state_machine: StateMachine
@export var air_state: State


var can_jump: bool = false
var jump_queued: bool = false
var has_jumped: bool = false


@onready var input_buffer: Timer = $InputBuffer
@onready var coyote_timer: Timer = $CoyoteTimer


# I don't like that the coyote time is here
# but for now it's cleaner to keep it here than somewhere else
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		input_buffer.start()


func _process(_delta: float) -> void:
	if player.is_on_floor() and state_machine.previous_state == air_state:
		has_jumped = false

	if player.is_on_floor():
		coyote_timer.start()
	

	can_jump = coyote_timer.is_stopped() == false
	jump_queued = input_buffer.is_stopped() == false


func consume() -> bool:
	if can_jump and jump_queued and has_jumped == false:
		input_buffer.stop()
		coyote_timer.stop()

		has_jumped = true
		return true
	return false
