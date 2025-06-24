extends Node

@onready var _file_dialog: FileDialog = $FileDialog

func _ready():
	_file_dialog.canceled.connect(_hide_dialog)
	_file_dialog.file_selected.connect(_hide_dialog)
	_file_dialog.dir_selected.connect(_hide_dialog)

## Shows a native FileDialog to selecte a directory.
## The provided callback is called with the selected directory
## on success.
func show_dir_dialog(p_on_dir_selected_callback: Callable):
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_file_dialog.dir_selected.connect(p_on_dir_selected_callback)
	_file_dialog.popup_centered_ratio(0.8)

## Shows a native FileDialog to select a file.
## The provided callback is called with the selected file on success.
## The optional parameter p_dir is used as the pre-selected directory.
func show_file_save_dialog(p_on_file_selected_callback: Callable, p_file_name: String = "", p_dir: String = ""):
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	
	if !p_file_name.is_empty():
		_file_dialog.current_file = p_file_name

	if !p_dir.is_empty():
		_file_dialog.current_dir = p_dir

	_file_dialog.file_selected.connect(p_on_file_selected_callback)

	_file_dialog.popup_centered_ratio(0.8)

func _hide_dialog():
	for connection in _file_dialog.file_selected.get_connections():
		_file_dialog.file_selected.disconnect(connection['callable'])
	for connection in _file_dialog.dir_selected.get_connections():
		_file_dialog.dir_selected.disconnect(connection['callable'])
