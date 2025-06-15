extends Window

const IMAGE_STORE_SETTINGS := &"image_store_settings"

@onready var _settings_list := %SettingsList as ItemList
@onready var _settings_container := %SettingsContainer as Control

@onready var _close_button := %CloseButton as Button

@onready var _image_settings_scene := load("res://ui/settings/image_settings.tscn") as PackedScene

func _ready():
	_init_settings_list()

	_settings_list.item_selected.connect(_on_settings_item_selected)

	close_requested.connect(hide)
	_close_button.pressed.connect(hide)

func _init_settings_list() -> void:
	_settings_list.add_item("Image store")
	_settings_list.set_item_metadata(0, IMAGE_STORE_SETTINGS)

func _on_settings_item_selected(p_index: int):
	var meta_data = _settings_list.get_item_metadata(p_index)
	match meta_data:
		IMAGE_STORE_SETTINGS: _show_settings_scene(_image_settings_scene)

func _show_settings_scene(p_scene: PackedScene):
	if _settings_container.get_children().size() > 0:
		var current_settings := _settings_container.get_child(0)
		_settings_container.remove_child(current_settings)

	var new_settings := p_scene.instantiate()
	_settings_container.add_child(new_settings)
