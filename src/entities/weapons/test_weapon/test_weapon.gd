extends HitscanWeapon


func _ready() -> void:
	var red: float = randf_range(0, 1)
	var green: float = randf_range(0, 1)
	var blue: float = randf_range(0, 1)
	$DebugModel.material = $DebugModel.material.duplicate()
	$DebugModel.material.albedo_color = Color(red, green, blue)
