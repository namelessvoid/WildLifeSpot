extends RefCounted

var _id: int = 1
var _name: String = "CmeraTrap"
var _manufacturer: String = "Trapvisor"
var _model: String = "SeeSharp 19"

func with_id(p_id: int):
	_id = p_id
	return self

func with_name(p_name: String):
	_name = p_name
	return self

func with_manufacturer(p_manufacturer: String):
	_manufacturer = p_manufacturer
	return self

func with_model(p_model: String):
	_model = p_model
	return self

func build() -> FSCamera:
	var camera := FSCamera.new()
	camera._id = _id
	camera.name = _name
	camera.manufacturer = _manufacturer
	camera.model = _model
	return camera
