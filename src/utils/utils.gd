class_name Utils
extends Node


# weight should usually be around 0 to 5 with 10 for instant
static func exp_decay(start: Variant, target: Variant, weight: float, delta: float) -> Variant:
	return target + (start - target) * exp(-weight * delta)
