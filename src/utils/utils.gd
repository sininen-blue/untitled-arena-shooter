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
