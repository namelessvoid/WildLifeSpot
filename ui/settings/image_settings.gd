extends Control

@onready var _image_store_path_edit := %ImageStorePathEdit as LineEdit
@onready var _image_store_path_select_button := %ImageStorePathSelectButton as Button

func _ready() -> void:
	_image_store_path_edit.text = Settings.get_setting(Settings.IMAGE_STORE, Settings.IMAGE_STORE_PATH)
	_image_store_path_edit.text_changed.connect(_save_image_store_path)
	
	_image_store_path_select_button.pressed.connect(_show_image_store_path_dialog)

func _save_image_store_path(p_path: String):
	Settings.set_setting(Settings.IMAGE_STORE, Settings.IMAGE_STORE_PATH, p_path)

func _on_file_dialog_dir_selected(p_dir: String):
	_image_store_path_edit.text = p_dir
	_save_image_store_path(p_dir)

func _show_image_store_path_dialog():
	FileDialogManager.show_dir_dialog(_on_file_dialog_dir_selected)
