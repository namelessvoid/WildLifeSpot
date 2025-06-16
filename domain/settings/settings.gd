extends Node

const IMAGE_STORE = &"image_store"
const IMAGE_STORE_PATH = &"path"
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
