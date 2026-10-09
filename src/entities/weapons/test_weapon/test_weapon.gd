extends HitscanWeapon


@onready var muzzle: Marker3D = $Muzzle


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	super._process(_delta)
	$Ammo.text = str(ammo)
