extends Window

const IMAGE_STORE_SETTINGS := &"image_store_settings"
const ANIMAL_SETTINGS := &"animal_settings"

@onready var _settings_list: ItemList = %SettingsList
@onready var _settings_container: Control = %SettingsContainer

@onready var _close_button: Button = %CloseButton

@onready var _image_settings_scene: PackedScene = load("res://ui/settings/image_settings.tscn")
@onready var _animal_settings: PackedScene = load("res://ui/animal_pictogram_search/animal_pictogram_search.tscn")

func _ready():
	_init_settings_list()

	_settings_list.item_selected.connect(_on_settings_item_selected)

	close_requested.connect(hide)
	_close_button.pressed.connect(hide)

func _init_settings_list() -> void:
	_settings_list.add_item("Image store")
	_settings_list.set_item_metadata(0, IMAGE_STORE_SETTINGS)

	_settings_list.add_item("Animals")
	_settings_list.set_item_metadata(1, ANIMAL_SETTINGS)

func _on_settings_item_selected(p_index: int):
	var meta_data = _settings_list.get_item_metadata(p_index)
	match meta_data:
		IMAGE_STORE_SETTINGS: _show_settings_scene(_image_settings_scene)
		ANIMAL_SETTINGS: _show_settings_scene(_animal_settings)

func _show_settings_scene(p_scene: PackedScene):
	if _settings_container.get_children().size() > 0:
		var current_settings := _settings_container.get_child(0)
		_settings_container.remove_child(current_settings)

	var new_settings := p_scene.instantiate()
	_settings_container.add_child(new_settings)
