extends AnimalSpotRepository
class_name AnimalSpotRepositorySQLite

const _table_name = &"animal_spot"

var _db: SQLite

func save(p_spot: AnimalSpot) -> void:
	if p_spot._id == -1:
		_db.insert_row(_table_name, {
			"source": p_spot.source,
			"file_path": p_spot.file_path,
			"camera_id": p_spot.camera_id,
			"spotted_at": p_spot.spotted_at,
			"animal_name": p_spot.animal_name,
			"animal_count": p_spot.animal_count
		})
	else:
		assert(false, "Updating spot is not implemented")

func find_all() -> Array[AnimalSpot]:
	_db.query("SELECT * FROM " + _table_name)
	return _deserialize(_db.query_result)

func find_all_by_date(date: String) -> Array[AnimalSpot]:
	_db.query_with_bindings(
		"SELECT * FROM " + _table_name + " WHERE DATE(spotted_at)=?",
		[date]
	)
	return _deserialize(_db.query_result)

func find_all_dates() -> PackedStringArray:
	_db.query("SELECT DISTINCT(DATE(spotted_at)) AS spotted_at FROM " + _table_name)

	var dates: PackedStringArray = []
	dates.resize(_db.query_result.size())

	for i in range(_db.query_result.size()):
		dates[i] = _db.query_result[i]["spotted_at"]

	return dates

func delete_by_source_and_spotted_at(source: String, spotted_at: String) -> void:
	var success = _db.query_with_bindings(
		"DELETE FROM " + _table_name + " WHERE source=? AND spotted_at=?",
		[source, spotted_at]
	)
	assert(success)

func set_db_path(p_db_path: String) -> void:
	if _db:
		_db.close_db()

	_db = SQLite.new()
	_db.path = p_db_path
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
		"spotted_at": { "data_type": "text", "not_null": true },
		"animal_name": { "data_type": "text", "not_null": true },
		"animal_count": { "data_type": "int", "not_null": true }
	})

static func _deserialize(query_result: Array[Dictionary]) -> Array[AnimalSpot]:
	var spots: Array[AnimalSpot] = []
	spots.resize(query_result.size())

	for i in range(query_result.size()):
		var serialized = query_result[i]
		var spot = AnimalSpot.new()
		spot._id = serialized.id
		spot.source = serialized.source
		spot.file_path = serialized.file_path
		spot.camera_id = serialized.camera_id
		spot.spotted_at = serialized.spotted_at
		spot.animal_name = serialized.animal_name
		spot.animal_count = serialized.animal_count
		spots[i] = spot

	return spots
