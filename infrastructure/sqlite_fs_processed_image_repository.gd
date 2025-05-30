extends FSProcessedImageRepository
class_name ProcessedImageRepositorySQLite

const _table_name = &"processed_image"

var _db: SQLite

func has_been_processed(file_hash: String) -> bool:
	var success = _db.query_with_bindings(
		"SELECT EXISTS(SELECT 1 FROM " + _table_name + " WHERE file_hash=?) AS hash_exists",
		[file_hash]
	)
	assert(success)
	return _db.query_result[0]["hash_exists"] == 1

func mark_processed(file_hash: String) -> void:
	if has_been_processed(file_hash):
		return

	_db.insert_row(_table_name, { "file_hash": file_hash })

func set_db_path(p_db_path: String) -> void:
	if _db:
		_db.close_db()

	_db = SQLite.new()
	_db.path = p_db_path
	_db.open_db()
	_ensure_table()

func _exit_tree() -> void:
	_db.close_db()

func _ensure_table() -> void:
	_db.create_table(_table_name, {
		"file_hash": { "data_type": "varchar(128)", "primary_key": true, "not_null": true },
	})
