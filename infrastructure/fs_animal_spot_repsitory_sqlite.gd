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
	return _deserialize(_db.query_result)

func find_all_by_date(date: String) -> Array[FSAnimalSpot]:
	_db.query_with_bindings(
		"SELECT * FROM " + _table_name + " WHERE DATE(date_time)=?",
		[date]
	)
	return _deserialize(_db.query_result)

func find_all_dates() -> PackedStringArray:
	_db.query("SELECT DISTINCT(DATE(date_time)) AS spot_date FROM " + _table_name)

	var dates: PackedStringArray = []
	dates.resize(_db.query_result.size())

	for i in range(_db.query_result.size()):
		dates[i] = _db.query_result[i]["spot_date"]

	return dates

func delete_by_source_and_date_time(source: String, date_time: String) -> void:
	var success = _db.query_with_bindings(
		"DELETE FROM " + _table_name + " WHERE source=? AND date_time=?",
		[source, date_time]
	)
	assert(success)

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

static func _deserialize(query_result: Array[Dictionary]) -> Array[FSAnimalSpot]:
	var spots: Array[FSAnimalSpot] = []
	spots.resize(query_result.size())

	for i in range(query_result.size()):
		var serialized = query_result[i]
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
