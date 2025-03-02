extends FSSpotRepository

var _file_path := &"user://Spots.json"

func save(p_spot: FSSpot) -> void:
	var spots := _find_all()
	spots.push_back(p_spot)
	_save_all(spots)

func file_hash_exists(p_hash: String) -> bool:
	return _find_all().any(func(s: FSSpot) -> bool:
		return s.hash == p_hash
	)

func _save_all(p_spots: Array[FSSpot]) -> void:
	var serialized := p_spots.map(_serialize)
	var json := JSON.stringify(serialized)

	var file = FileAccess.open(_file_path, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return

	file.store_string(json)

func _find_all() -> Array[FSSpot]:
	var json = FileAccess.get_file_as_string(_file_path)
	if FileAccess.get_open_error() != OK:
		print(FileAccess.get_open_error())
	
	if json.is_empty():
		return []

	var serialized_spots = JSON.parse_string(json)
	
	var spots: Array[FSSpot] = []
	for serialized_spot in serialized_spots:
		spots.push_back(_deserialize(serialized_spot))

	return spots

func _serialize(p_spot: FSSpot) -> Dictionary:
	return {
		"type": p_spot.type,
		"file_hash": p_spot.file_hash,
		"file_path": p_spot.file_path,
		"date": p_spot.date,
		"temperature": p_spot.temperature,
		"animals": p_spot.animals
	}

func _deserialize(p_dict) -> FSSpot:
	var spot := FSSpot.new()
	spot.type = p_dict["type"]
	spot.file_hash = p_dict["file_hash"]
	spot.file_path = p_dict["file_path"]
	spot.date = p_dict["date"]
	spot.animals = p_dict["animals"]
	return spot
