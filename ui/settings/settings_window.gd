extends Window

const IMAGE_STORE_SETTINGS := &"image_store_settings"
const ANIMAL_SETTINGS := &"animal_settings"

@onready var _settings_list: ItemList = %SettingsList
@onready var _settings_stack: StackContainer = %SettingsContainer

@onready var _close_button: Button = %CloseButton

@onready var _image_settings_scene: PackedScene = load("res://ui/settings/image_settings.tscn")
@onready var _animal_settings: PackedScene = load("uid://b80f2ewpbp12u")

func _ready():
	assert(_settings_list)
	assert(_settings_stack)
	assert(_close_button)

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
		IMAGE_STORE_SETTINGS: _show_settings_scene("Image Store", _image_settings_scene)
		ANIMAL_SETTINGS: _show_settings_scene("Animals", _animal_settings)

func _show_settings_scene(p_name: String, p_scene: PackedScene):
	_settings_stack.clear()

	var new_settings := p_scene.instantiate()
	_settings_stack.push(p_name, new_settings)

	if new_settings.has_signal("push_settings"):
		new_settings.push_settings.connect(_push_settings)
	
	if new_settings.has_signal("pop_settings"):
		new_settings.pop_settings.connect(_pop_settings)

func _push_settings(p_name: String, p_control: Control):
	_settings_stack.push(p_name, p_control)

func _pop_settings():
	_settings_stack.pop()
