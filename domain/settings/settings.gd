extends Node

const IMAGE_STORE = &"image_store"
const IMAGE_STORE_PATH = &"path"
const ANIMALS = &"animals"

const DEFAULTS = {
	IMAGE_STORE: {
		IMAGE_STORE_PATH: &"user://images"
	}
}

var _config_file: ConfigFile
var _config_file_path := &"user://settings.ini"

func _ready() -> void:
	_config_file = ConfigFile.new()
	var error := _config_file.load(_config_file_path)

	if error != OK:
		print("Could not open config file. Using defaults.")

func get_setting(p_section: StringName, p_setting: StringName) -> Variant:
	var default = DEFAULTS[p_section][p_setting]
	return _config_file.get_value(p_section, p_setting, default)

func set_setting(p_section: StringName, p_setting: StringName, p_value: Variant) -> void:
	_config_file.set_value(p_section, p_setting, p_value)
	var error := _config_file.save(_config_file_path)

	if error != OK:
		push_error("Failed to save config file. Error code: %s" % error)

func get_or_create_animal_setting(p_animal_name: String) -> Dictionary:
	var animal_setting: Dictionary = _config_file.get_value(ANIMALS, p_animal_name, {})
	if animal_setting.is_empty():
		animal_setting = { "color": _random_color(), "icon_path": "" }
		set_setting(ANIMALS, p_animal_name, animal_setting)

	return animal_setting

func _random_color() -> Color:
	return Color.from_hsv(
		randf(),
		randf_range(0.2, 0.6),
		randf_range(0.9, 1.0),
	)
