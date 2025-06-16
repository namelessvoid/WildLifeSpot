extends Control

@onready var _image_store_path_edit := %ImageStorePathEdit as LineEdit

func _ready() -> void:
	_image_store_path_edit.text = Settings.get_setting(Settings.IMAGE_STORE, Settings.IMAGE_STORE_PATH)
	_image_store_path_edit.text_changed.connect(func(p_value: String):
		Settings.set_setting(Settings.IMAGE_STORE, Settings.IMAGE_STORE_PATH, p_value)
	)
