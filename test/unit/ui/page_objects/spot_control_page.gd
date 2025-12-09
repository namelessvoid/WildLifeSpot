extends RefCounted

const SpotControl := preload("uid://cmcpbtxk0apc6")
const AnimalBoxPage = preload("uid://cdqjxbt7eeffe")

var _spot_control: SpotControl
var _input_sender: GutInputSender

func _init(p_spot_control: SpotControl):
	_spot_control = p_spot_control
	_input_sender = GutInputSender.new(Input)
	#_input_sender = GutInputSender.new(Input)
	_input_sender.add_receiver(_spot_control.get_node("%AddNewAnimalButton"))

func get_date() -> String:
	var line_edit := _get_date_edit()
	return line_edit.text

func enter_date(p_date: String) -> void:
	var line_edit := _get_date_edit()
	line_edit.text = p_date
	line_edit.editing_toggled.emit(false)

func get_time() -> String:
	var line_edit: LineEdit = _get_time_edit()
	return line_edit.text

func enter_time(p_time: String) -> void:
	var line_edit := _get_time_edit()
	line_edit.text = p_time
	line_edit.editing_toggled.emit(false)

func get_selected_source_label() -> String:
	var option_button: OptionButton = _get_source_options_button()
	return option_button.get_item_text(option_button.selected)

func get_all_source_labels() -> Array[String]:
	var option_button := _get_source_options_button()
	var labels: Array[String] = []
	for i in option_button.item_count:
		labels.push_back(option_button.get_item_text(i))
	return labels

func get_selected_camera_id() -> int:
	var option_button: OptionButton = _get_camera_options_button()
	return option_button.get_item_id(option_button.selected)

func get_all_camera_labels() -> Array[String]:
	var option_button := _get_camera_options_button()
	var labels: Array[String] = []
	for i in option_button.item_count:
		labels.push_back(option_button.get_item_text(i))
	return labels

func animal_box_count() -> int:
	return _get_animal_box_container().get_child_count()

func press_add_animal_box_button() -> void:
	var button: Button = _spot_control._add_new_animal_button
	button.pressed.emit()

func press_remove_animal_box_button(p_index: int) -> void:
	_get_animal_box_at(p_index).press_remove_button()

func enter_animal_name(p_index: int, p_name: String) -> void:
	_get_animal_box_at(p_index).enter_animal_name(p_name)

func enter_animal_count(p_index: int, p_count: int) -> void:
	_get_animal_box_at(p_index).enter_animal_count(p_count)

func _get_date_edit() -> LineEdit:
	return _spot_control._date_edit

func _get_time_edit() -> LineEdit:
	return _spot_control._time_edit

func _get_animal_box_at(p_index: int) -> AnimalBoxPage:
	var animal_box: AnimalBox = _get_animal_box_container().get_child(p_index)
	return AnimalBoxPage.new(animal_box)

func _get_animal_box_container() -> Container:
	return _spot_control._animal_box_container

func _get_source_options_button() -> OptionButton:
	return _spot_control._source_options_button

func _get_camera_options_button() -> OptionButton:
	return _spot_control._camera_options_button
