extends FSCameraRepository

var _file_path := &"user://Cameras.json"

func find_all() -> Array[FSCamera]:
	var json = FileAccess.get_file_as_string(_file_path)
	if FileAccess.get_open_error() != OK:
		print(FileAccess.get_open_error())
	
	if json.is_empty():
		return []

	var serialized_cameras = JSON.parse_string(json)
	
	var cameras: Array[FSCamera] = []
	for serialized_camera in serialized_cameras:
		var camera = _deserialize(serialized_camera)
		cameras.push_back(camera)

	return cameras

func save(p_camera: FSCamera) -> void:
	var cameras = find_all()
	if p_camera._id == -1:
		var highest_id := 0
		for c in cameras:
			if highest_id <= c._id:
				highest_id = c._id + 1
		p_camera._id = highest_id
	else:
		cameras = cameras.filter(func(c) -> bool:
			return c._id != p_camera._id
		)

	cameras.push_back(p_camera)
	_save_all(cameras)

func delete(p_camera: FSCamera) -> void:
	var cameras = find_all()
	cameras = cameras.filter(func(c) -> bool:
		return c._id != p_camera._id
	)
	_save_all(cameras)

func _save_all(p_cameras: Array[FSCamera]):
	var serialized = p_cameras.map(_serialize)
	var json = JSON.stringify(serialized)

	var file = FileAccess.open(_file_path, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return

	file.store_string(json)

func _serialize(p_camera: FSCamera) -> Dictionary:
	return {
		'_id': p_camera._id,
		'name': p_camera.name,
		'manufacturer': p_camera.manufacturer,
		'model': p_camera.model
	}

func _deserialize(p_dict: Dictionary) -> FSCamera:
	var camera = FSCamera.new()
	camera._id = p_dict['_id']
	camera.name = p_dict['name']
	camera.manufacturer = p_dict['manufacturer']
	camera.model = p_dict['model']
	return camera
