class_name FSSpot
extends RefCounted

var type: String = "image"
var file_path: String
var file_hash: String
var date_time: String
var temperature: int
var animals: Dictionary
var camera_id: int

func get_date() -> String:
	return date_time.get_slice("T", 0)
