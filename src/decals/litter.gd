@tool
extends GroundDecal


const LITTER_1 = preload("uid://qhp345t75571")
const LITTER_2 = preload("uid://bevo6n3omhchp")
const LITTER_3 = preload("uid://uw7mp0gy2a1n")
const LITTER_4 = preload("uid://byji6pmg6ql62")
const LITTER_5 = preload("uid://g08anqtcrn5e")
const LITTER_6 = preload("uid://u8ttld41ewxl")
const LITTER_7 = preload("uid://biwjqkydod0hy")
const LITTER_8 = preload("uid://bphl5wo0crlr8")
const LITTER_9 = preload("uid://bukdy254owm3h")
const LITTER_10 = preload("uid://cgmxavwebwys4")


func _ready() -> void:
	self.cull_mask &= ~(1 << 9)
	var textures := [
		LITTER_1,
		LITTER_2,
		LITTER_3,
		LITTER_4,
		LITTER_5,
		LITTER_6,
		LITTER_7,
		LITTER_8,
		LITTER_9,
		LITTER_10,
	]
	
	self.rotation_degrees.y = randf_range(-360, 360)
	self.texture_albedo = textures.pick_random()
