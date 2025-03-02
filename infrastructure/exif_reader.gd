class_name ExifReader
extends Node

func get_exif_info(p_file_path: String) -> ExifInfo:
	match OS.get_name():
		"Linux": return _get_exif_linux(p_file_path)
		_:
			_log_unavailable()
			return null

func _get_exif_linux(p_file_path: String) -> ExifInfo:
	var output_array: Array[String] = []
	var error_code = OS.execute("exiv2", [p_file_path], output_array)
	if error_code != 0:
		push_error("Calling exiv2 failed with error code: %d" % error_code)
		return null

	var exif_info = ExifInfo.new()
	var output_lines: PackedStringArray = output_array[0].split("\n")
	for line in output_lines:
		var lower_line = line.to_lower()
		if lower_line.begins_with("camera make"):
			exif_info.camera_make = line.split(" : ")[1].strip_edges()
		elif lower_line.begins_with("image timestamp"):
			var date_time: PackedStringArray = line.split(" : ")[1].strip_edges().split(" ")
			if date_time.size() == 2:
				var date = date_time[0].replace(":", "-")
				var time = date_time[1]
				exif_info.date_time = "%sT%s" % [date, time]
	return exif_info

func _log_unavailable():
	print("ExifReader is not implement on %s" % OS.get_name())
