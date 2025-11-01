extends Control

const AnimalPictogramSearch := preload("uid://xpo847h5qv8g")
const _animal_pictogram_search_scene := preload("uid://dxcp2nuu3oeew")

const AnimalSettingsItem := preload("uid://cwrmvbs6f75j3")
const _animal_settings_item_scene := preload("uid://nu4u600nvbe0")

@onready var _stack_container: StackContainer = $StackContainer
@onready var _animal_settings_container: GridContainer

func _ready() -> void:
	_animal_settings_container = GridContainer.new()
	_animal_settings_container.columns = 4
	_stack_container.push("Animal settings", _animal_settings_container)

	var query := FindAllAnimalSpotAnimalNamesQuery.new()
	var animal_names: PackedStringArray = CommandQueryDispatcher.dispatch(query)

	for animal_name in animal_names:
		var animal_setting := Settings.get_or_create_animal_setting(animal_name)
		var control := _create_animal_settings_control(animal_name, animal_setting)
		_animal_settings_container.add_child(control)

func _create_animal_settings_control(p_animal_name: String, p_animal_setting: Dictionary) -> Control:
	var single_animal_setting: AnimalSettingsItem = _animal_settings_item_scene.instantiate()
	single_animal_setting.animal_settings = p_animal_setting
	single_animal_setting.animal_name = p_animal_name

	single_animal_setting.pick_icon_button_pressed.connect(func():
		_on_icon_button_pressed(p_animal_name)
	)
	single_animal_setting.color_changed.connect(func(p_color: Color):
		_on_animal_color_picker_color_changed(p_animal_name, p_color, single_animal_setting)
	)

	return single_animal_setting

func _on_animal_color_picker_color_changed(p_animal_name: String, p_color: Color, p_animal_settings_item: AnimalSettingsItem):
	var animal_setting := Settings.get_or_create_animal_setting(p_animal_name)
	animal_setting["color"] = p_color
	Settings.set_setting(Settings.ANIMALS, p_animal_name, animal_setting)
	p_animal_settings_item.update()

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
