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
	var line_edit: LineEdit = _spot_control.get_node("%DateEdit")
	return line_edit.text

func get_time() -> String:
	var line_edit: LineEdit = _spot_control.get_node("%TimeEdit")
	return line_edit.text

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
	var button: Button = _spot_control.get_node("%AddNewAnimalButton")
	button.pressed.emit()

func press_remove_animal_box_button(p_index: int) -> void:
	_get_animal_box_at(p_index).press_remove_button()

func _get_animal_box_at(p_index: int) -> AnimalBoxPage:
	var animal_box: AnimalBox = _get_animal_box_container().get_child(p_index)
	return AnimalBoxPage.new(animal_box)

func _get_animal_box_container() -> Container:
	return _spot_control._animal_box_container

func _get_source_options_button() -> OptionButton:
	return _spot_control._source_options_button

func _get_camera_options_button() -> OptionButton:
	return _spot_control._camera_options_button
