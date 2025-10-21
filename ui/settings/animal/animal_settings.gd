extends Control

const AnimalPictogramSearch := preload("uid://xpo847h5qv8g")
const _animal_pictogram_search_scene := preload("uid://dxcp2nuu3oeew")

const SingleAnimalSetting := preload("uid://cwrmvbs6f75j3")
const _single_animal_seting_scene := preload("uid://nu4u600nvbe0")

@onready var _stack_container: StackContainer = $StackContainer
@onready var _animal_settings_container: VBoxContainer

func _ready() -> void:
	_animal_settings_container = VBoxContainer.new()
	_stack_container.push("Animal settings", _animal_settings_container)

	var query := FindAllAnimalSpotAnimalNamesQuery.new()
	var animal_names: PackedStringArray = CommandQueryDispatcher.dispatch(query)

	for animal_name in animal_names:
		var animal_setting := Settings.get_or_create_animal_setting(animal_name)
		var control := _create_animal_settings_control(animal_name, animal_setting)
		_animal_settings_container.add_child(control)

func _create_animal_settings_control(p_animal_name: String, p_animal_setting: Dictionary) -> Control:
	var single_animal_setting: SingleAnimalSetting = _single_animal_seting_scene.instantiate()
	single_animal_setting.animal_settings = p_animal_setting
	single_animal_setting.animal_name = p_animal_name

	single_animal_setting.pick_icon_button_pressed.connect(func():
		_on_icon_button_pressed(p_animal_name)
	)
	single_animal_setting.color_changed.connect(func(p_color: Color):
		_on_animal_color_picker_color_changed(p_animal_name, p_color)
	)

	return single_animal_setting

func _on_animal_color_picker_color_changed(p_animal_name: String, p_color: Color):
	var animal_setting := Settings.get_or_create_animal_setting(p_animal_name)
	animal_setting["color"] = p_color
	Settings.set_setting(Settings.ANIMALS, p_animal_name, animal_setting)

func _on_icon_button_pressed(p_animal_name: String) -> void:
	var scene: AnimalPictogramSearch = _animal_pictogram_search_scene.instantiate()
	_stack_container.push("Pictogram search", scene)
	scene.animal_name = p_animal_name
	scene.pictogram_selected.connect(func(p_image: Image):
		_on_pictogram_selected(p_animal_name, p_image)
	)

func _on_pictogram_selected(p_animal_name: String, p_image: Image) -> void:
	DirAccess.make_dir_absolute("user://animal_pictograms")
	var animal_setting := Settings.get_or_create_animal_setting(p_animal_name)
	var path := "user://animal_pictograms/%s.png" % p_animal_name
	p_image.save_png(path)
	animal_setting["icon_path"] = path
	Settings.set_setting(Settings.ANIMALS, p_animal_name, animal_setting)
