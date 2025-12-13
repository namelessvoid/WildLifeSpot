extends VBoxContainer

const _animal_box_scene := preload("uid://1igx7b8aya")

var date_time: String:
	get: return _date_edit.text + "T" + _time_edit.text
	set(value):
		var split := value.split("T")
		_date_edit.text = split[0]
		_time_edit.text = split[1]

var camera_id: int:
	get: return _camera_options_button.get_item_id(_camera_options_button.selected)
	set(_value): assert(false, "Cannot set camera_id of SpotControl")

@onready var _date_edit: ValidatableLineEdit = %DateEdit
@onready var _time_edit: ValidatableLineEdit = %TimeEdit
@onready var _source_options_button: OptionButton = %SourceOptionsButton
@onready var _camera_options_button: OptionButton = %CameraOptionsButton
@onready var _animal_box_container: VBoxContainer = %AnimalBoxContainer
@onready var _add_new_animal_button: Button = %AddNewAnimalButton

func _ready() -> void:
	assert(_date_edit)
	assert(_time_edit)
	assert(_source_options_button)
	assert(_camera_options_button)
	assert(_animal_box_container)
	assert(_add_new_animal_button)

	_date_edit.validator = func(p_value: Variant) -> bool:
		return DateTimeUtils.IsValidDate(p_value as String)
	_time_edit.validator = func(p_value: Variant) -> bool:
		return DateTimeUtils.IsValidTime(p_value as String)

	for source in AnimalSpot.Sources():
		print(source)
		_source_options_button.add_item(source)

	_add_new_animal_button.pressed.connect(_add_animal_box)
	_date_edit.text_changed.connect(_on_date_edit_text_changed)
	_time_edit.text_changed.connect(_on_time_edit_text_toggled)

func reset() -> void:
	var all_cameras: Array[FSCamera] = CommandQueryDispatcher.dispatch(FindAllCamerasQuery.new())
	_camera_options_button.clear()
	for camera in all_cameras:
		_camera_options_button.add_item(camera.name, camera._id)

	_date_edit.text = ""
	_time_edit.text = ""

	if _camera_options_button.item_count > 0:
		_camera_options_button.select(0)

	for animal_box in _animal_box_container.get_children():
		_animal_box_container.remove_child(animal_box)
		animal_box.queue_free()
	_add_animal_box()

func reset_to_spots(spots: Array[AnimalSpot]) -> void:
	var animal_count_map := {}
	for spot in spots:
		animal_count_map[spot.AnimalName] = spot.AnimalCount

	for animal_box_node in _animal_box_container.get_children():
		var animal_box := animal_box_node as AnimalBox
		var animal_name := animal_box.get_animal_name()
		var existing_count: int = animal_count_map.get(animal_name, 0)
		animal_box.set_animal_count(existing_count)
		animal_count_map.erase(animal_name)

	for unmapped_animal_name in animal_count_map:
		var unmapped_animal_count = animal_count_map[unmapped_animal_name]
		var animal_box := _animal_box_container.get_child(
			_animal_box_container.get_child_count() - 1
		) as AnimalBox
		if !animal_box.get_animal_name().is_empty():
			_add_animal_box()
			animal_box = _animal_box_container.get_child(
				_animal_box_container.get_child_count() - 1
			) as AnimalBox
		animal_box.set_animal_name(unmapped_animal_name)
		animal_box.set_animal_count(unmapped_animal_count)

func set_all_animal_counts_to_zero() -> void:
	for box_node in _animal_box_container.get_children():
		var animal_box: AnimalBox = box_node
		animal_box.set_animal_count(0)

func create_spots() -> Array[AnimalSpot]:
	var spots: Array[AnimalSpot] = []
	for node in _animal_box_container.get_children():
		var animal_box := node as AnimalBox
		if animal_box.get_animal_name().is_empty() || animal_box.get_animal_count() <= 0:
			continue

		var spot = AnimalSpot.new()
		spot.Source = AnimalSpot.SourceCameraImage()
		spot.SpottedAt = date_time
		spot.AnimalName = animal_box.get_animal_name()
		spot.AnimalCount = animal_box.get_animal_count()
		spot.CameraId = camera_id
		
		spots.append(spot)

	return spots

func _add_animal_box() -> void:
	_animal_box_container.add_child(_animal_box_scene.instantiate())

func _on_date_edit_text_changed(p_text: String) -> void:
	if _date_edit.is_valid():
		_date_edit.text = DateTimeUtils.ParseDate(p_text)

func _on_time_edit_text_toggled(p_text: String) -> void:
	if _time_edit.is_valid():
		_time_edit.text = DateTimeUtils.ParseTime(p_text)
