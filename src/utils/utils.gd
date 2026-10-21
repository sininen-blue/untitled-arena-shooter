class_name Utils
extends Node


# weight should usually be around 0 to 5 with 10 for instant
static func exp_decay(start: Variant, target: Variant, weight: float, delta: float) -> Variant:
	return target + (start - target) * exp(-weight * delta)


static func exp_decay_curved(
	start: Variant,
	target: Variant,
	weight: float,
	delta: float,
	curve: Curve
) -> Variant:
	var t := 1.0 - exp(-weight * delta)
	var shaped_t := curve.sample_baked(t)
	return start + (target - start) * shaped_t


static func sender_id(node: Node) -> int:
	var id := node.multiplayer.get_remote_sender_id()
	if id == 0:
		return node.multiplayer.get_unique_id()
	return id


static func player_children(root: Node) -> Array:
	return root.get_children().filter(func(child: Node) -> bool: return child is Player)


static func find_player(player_name: String, root: Node) -> Player:
	for child: Node in root.get_children():
		if child is Player and child.name == player_name:
			return child
	return null
