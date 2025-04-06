extends FSAnimalSpotRepository

var _db_path = &"user://wildlifespot.db"
const _table_name = &"animal_spot"

var _db: SQLite

func save(p_spot: FSAnimalSpot) -> void:
	if p_spot._id == -1:
		_db.insert_row(_table_name, {
			"source": p_spot.source,
			"file_path": p_spot.file_path,
			"camera_id": p_spot.camera_id,
			"date_time": p_spot.date_time,
			"animal_name": p_spot.animal_name,
			"animal_count": p_spot.animal_count
		})
	else:
		assert(false, "Updating spot is not implemented")

func find_all() -> Array[FSAnimalSpot]:
	_db.query("SELECT * FROM " + _table_name)

	var spots: Array[FSAnimalSpot] = []
	spots.resize(_db.query_result.size())
	for i in range(_db.query_result.size()):
		var serialized = _db.query_result[i]
		var spot = FSAnimalSpot.new()
		spot._id = serialized.id
		spot.source = serialized.source
		spot.file_path = serialized.file_path
		spot.camera_id = serialized.camera_id
		spot.date_time = serialized.date_time
		spot.animal_name = serialized.animal_name
		spot.animal_count = serialized.animal_count
		spots[i] = spot

	return spots

func _ready() -> void:
	_db = SQLite.new()
	_db.path = _db_path
	_db.open_db()
	_ensure_table()

func _exit_tree() -> void:
	_db.close_db()

func _ensure_table():
	_db.create_table(_table_name, {
		"id": { "data_type": "int", "primary_key": true, "not_null": true },
		"source": { "data_type": "char(10)", "not_null": true },
		"file_path": { "data_type": "text", "not_null": false },
		"camera_id": { "data_type": "int", "not_null": false },
		"date_time": { "data_type": "text", "not_null": true },
		"animal_name": { "data_type": "text", "not_null": true },
		"animal_count": { "data_type": "int", "not_null": true }
	})
