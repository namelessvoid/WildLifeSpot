extends Node
class_name SettingsRepository

func get_setting(p_setting: String) -> Variant:
	if p_setting == Settings.IMAGE_STORE_PATH:
		return "test/path"
	return null

func set_setting(p_setting: String, p_value: Variant) -> void:
	pass
