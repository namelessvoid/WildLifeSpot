extends FSCameraRepository
class_name CameraRepositorySQLite

const _table_name = &"camera"

var _db: SQLite

func find_all() -> Array[FSCamera]:
	var rows = _db.select_rows(_table_name, "", ["*"])
	var cameras: Array[FSCamera] = []
	cameras.resize(rows.size())

	for i in range(rows.size()):
		var camera := FSCamera.new()
		camera._id = rows[i]["id"]
		camera.name = rows[i]["name"]
		camera.manufacturer = rows[i]["manufacturer"]
		camera.model = rows[i]["model"]
		cameras[i] = camera

	return cameras

func save(camera: FSCamera) -> void:
	if camera._id == -1:
		_db.insert_row(_table_name, {
			"name": camera.name,
			"manufacturer": camera.manufacturer,
			"model": camera.model
		})
		camera._id = _db.last_insert_rowid
	else:
		_db.query("BEGIN TRANSACTION;")
		_db.query_with_bindings("UPDATE " + _table_name + "
			SET name=?, manufacturer=?, model=?
			WHERE id=?
		", [camera.name, camera.manufacturer, camera.model, camera._id])
		_db.query("END TRANSACTION;")

func delete(p_id: int) -> void:
	_db.query("BEGIN TRANSACTION;")
	_db.query_with_bindings(
		"DELETE FROM " + _table_name + " WHERE id=?",
		[p_id]
	)
	_db.query("END TRANSACTION;")

func set_db_path(p_db_path: String) -> void:
	if _db:
		_db.close_db()

	_db = SQLite.new()
	_db.path = p_db_path
	_db.open_db()
	_ensure_table()

	db_changed.emit()

func _exit_tree() -> void:
	_db.close_db()

func _ensure_table() -> void:
	_db.create_table(_table_name, {
		"id": { "data_type": "int", "primary_key": true, "not_null": true },
		"name": { "data_type": "text", "not_null": true },
		"manufacturer": { "data_type": "text", "not_null": true },
		"model": { "data_type": "text", "not_null": true }
	})
