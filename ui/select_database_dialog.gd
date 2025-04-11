extends FileDialog

@export var database_manager: DatabaseManagerSQLite

func _ready():
	file_selected.connect(_on_file_selected)

func show_create():
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	ok_button_text = "Create"
	title = "Create database"
	show()

func show_load():
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	ok_button_text = "Load"
	title = "Load database"
	show()

func _on_file_selected(p_path):
	assert(database_manager)

	database_manager.set_db_path(p_path)
