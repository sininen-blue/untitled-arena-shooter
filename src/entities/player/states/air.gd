extends State

@export var player: Player
@export var idle_state: State
@export var walk_state: State
@export var run_state: State



func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	player.velocity += player.get_gravity() * player.mass * delta
	
	if player.is_on_floor():
		if Input.is_action_pressed("run") and player.direction.length() > 0:
			state_machine.change_state(run_state)
		elif player.direction.length() > 0:
			state_machine.change_state(walk_state)
		else:
			state_machine.change_state(idle_state)


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
