extends RefCounted
class_name DeleteExistingAnimalSpots

var _source: String
var _spotted_at: String

func _init(p_source: String, p_spotted_at: String) -> void:
	_source = p_source
	_spotted_at = p_spotted_at
