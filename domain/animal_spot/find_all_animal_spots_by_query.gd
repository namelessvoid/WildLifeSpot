extends RefCounted
class_name FindAllAnimalSpotsByQuery

var _source: String
var _camera_id: int
var _spotted_at: String

func _init(p_source: String, p_camera_id: int, p_spotted_at: String):
	_source = p_source
	_camera_id = p_camera_id
	_spotted_at = p_spotted_at
