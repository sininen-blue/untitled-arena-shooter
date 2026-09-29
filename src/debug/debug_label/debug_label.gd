class_name DebugLabel
extends Label

@export var target: Node
@export_enum("property", "function") var member_type: String = "property"
@export var property: String


func _ready() -> void:
	if is_multiplayer_authority() == false and multiplayer.get_peers().is_empty() == false:
		self.visible = false
		return
	self.visible = true


func _process(_delta: float) -> void:
	if target == null:
		return
	
	var prompt: String = property.to_pascal_case() + ": "
	
	if member_type == "function":
		if target.has_method(property):
			prompt += str(target.call(property))
		else:
			prompt += "Can't find function"
	else: 
		if property in target:
			prompt += str(target.get(property))
		else:
			prompt += "Can't find property"
	
	self.text = prompt
