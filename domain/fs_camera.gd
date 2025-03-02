class_name FSCamera
extends RefCounted

var _id: int
var name: String
var manufacturer: String
var model: String

func _init():
	_id = -1
	name = 'New Camera'
	manufacturer = 'Unknown manufacturer'
	model = 'Unknown model'
