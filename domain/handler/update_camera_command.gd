extends RefCounted
class_name UpdateCameraCommand

var _id: int
var _name: String
var _manufacturer: String
var _model: String

func _init(p_id: int, p_name: String, p_manufacturer: String, p_model: String):
	_id = p_id
	_name = p_name
	_manufacturer = p_manufacturer
	_model = p_model
