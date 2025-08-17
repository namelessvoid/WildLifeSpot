extends Control

const _animal_pictogram_search_scene := preload("res://ui/animal_pictogram_search/animal_pictogram_search.tscn")

@onready var _stack_container: StackContainer = $StackContainer
@onready var _animal_tree: VBoxContainer = %AnimalSettingsContainer

func _ready() -> void:
	var query := FindAllAnimalSpotAnimalNamesQuery.new()
	var animal_names: PackedStringArray = CommandQueryDispatcher.dispatch(query)

	for animal_name in animal_names:
		var animal_setting := Settings.get_or_create_animal_setting(animal_name)
		var control := _create_animal_settings_control(animal_name, animal_setting)
		_animal_tree.add_child(control)

func _create_animal_settings_control(p_animal_name: String, p_animal_setting: Dictionary) -> Control:
	var hbox := HBoxContainer.new()

	var color_picker_button := ColorPickerButton.new()
	color_picker_button.color = p_animal_setting["color"]
	color_picker_button.flat = true
	color_picker_button.text = " "
	color_picker_button.custom_minimum_size = Vector2(26, 0)
	color_picker_button.color_changed.connect(func(p_color: Color):
		_on_animal_color_picker_color_changed(p_animal_name, p_color)
	)
	hbox.add_child(color_picker_button)

	var name_label := Label.new()
	name_label.text = p_animal_name
	hbox.add_child(name_label)

	return hbox

func _on_animal_color_picker_color_changed(p_animal_name: String, p_color: Color):
	var animal_setting := Settings.get_or_create_animal_setting(p_animal_name)
	animal_setting["color"] = p_color
	Settings.set_setting(Settings.ANIMALS, p_animal_name, animal_setting)
