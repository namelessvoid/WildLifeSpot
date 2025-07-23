extends RefCounted

var _date_time: String = "2024-10-03T14:01:15"
var _camera_make: String = "WildLifeCam 200"

func with_date_time(p_date_time: String):
	_date_time = p_date_time
	return self

func with_camera_make(p_camera_make: String):
	_camera_make = p_camera_make
	return self

func build():
	var exif_info = ExifInfo.new()
	exif_info.DateTime = _date_time
	exif_info.CameraMake = _camera_make
	return exif_info
