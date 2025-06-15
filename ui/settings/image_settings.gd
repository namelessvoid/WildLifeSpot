extends Control

@onready var _image_store_path_edit := %ImageStorePathEdit as LineEdit

func _ready() -> void:
	var image_store_path_query = GetSettingsQuery.new(Settings.IMAGE_STORE_PATH)
	_image_store_path_edit.text = CommandQueryDispatcher.dispatch(image_store_path_query)
