extends Control

@onready var _image_store_path_edit := %ImageStorePathEdit as LineEdit
@onready var _image_store_path_select_button := %ImageStorePathSelectButton as Button

func _ready() -> void:
	_image_store_path_edit.text = Settings.get_setting(Settings.IMAGE_STORE, Settings.IMAGE_STORE_PATH)
	_image_store_path_edit.text_changed.connect(_save_image_store_path)
	
	_image_store_path_select_button.pressed.connect(_show_image_store_path_dialog)

func _save_image_store_path(p_path: String):
	Settings.set_setting(Settings.IMAGE_STORE, Settings.IMAGE_STORE_PATH, p_path)

func _show_image_store_path_dialog():
	var dialog := FileDialog.new()
	add_child(dialog)
	dialog.use_native_dialog = true
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.dir_selected.connect(func(p_dir: String):
		_image_store_path_edit.text = p_dir
		_save_image_store_path(p_dir)
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered_ratio(0.8)
	
