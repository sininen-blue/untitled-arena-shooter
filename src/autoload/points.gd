extends Node


var points: Dictionary[String, int]


func get_points(player_name: String) -> int:
	return points.get(player_name, 0)


func add(player_name: String, amount: int) -> void:
	points[player_name] += amount


func remove(player_name: String, amount: int) -> void:
	points[player_name] -= amount
