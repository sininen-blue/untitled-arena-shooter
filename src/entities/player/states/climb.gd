extends State


@export var wall_raycasts: WallRaycasts
@export var player: Player

@export var climb_speed: float = 10.0


func enter() -> void:
	pass


func exit(_new_state: State) -> void:
	pass


func update(_delta: float) -> void:
	if not wall_raycasts.front_is_colliding():
		pass
	# get front of player basis.z negative
	# check dot between that and wall collided
	# if greater than something, drop
	# if wall not ladder drop
	# if jump drop
	
	#if moving towards the collided wall go up
	
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func can_enter() -> bool:
	return true
