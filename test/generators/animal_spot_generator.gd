extends Node

var _id = -1
var _source: String = "image"
var _file_path: String = ""
var _camera_id: int = 2
var _spotted_at: String = "2024-10-03T14:01:15"
var _animal_name: String = "Lion"
var _animal_count: int = 3

func with_id(p_id: int):
	_id = p_id
	return self

func with_source(p_source: String):
	_source = p_source
	return self

func with_file_path(p_file_path: String):
	_file_path = p_file_path
	return self

func with_camera_id(p_camera_id: int):
	_camera_id = p_camera_id
	return self

func with_spotted_at(p_spotted_at: String):
	_spotted_at = p_spotted_at
	return self

func with_animal_name(p_animal_name: String):
	_animal_name = p_animal_name
	return self

func with_animal_count(p_animal_count: int):
	_animal_count = p_animal_count
	return self

func build():
	var spot = AnimalSpot.new()
	spot._id = _id
	spot.source = _source
	spot.file_path = _file_path
	spot.camera_id = _camera_id
	spot.spotted_at = _spotted_at
	spot.animal_name = _animal_name
	spot.animal_count = _animal_count
	return spot
