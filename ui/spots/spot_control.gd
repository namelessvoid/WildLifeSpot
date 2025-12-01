extends VBoxContainer

const _animal_box_scene := preload("uid://1igx7b8aya")

var date_time: String:
	get: return _date_time_edit.text
	set(value): _date_time_edit.text = value

var camera_id: int:
	get: return _camera_options_button.get_item_id(_camera_options_button.selected)
	set(_value): assert(false, "Cannot set camera_id of SpotControl")

@onready var _date_time_edit: LineEdit = %DateTimeEdit
@onready var _camera_options_button: OptionButton = %CameraOptionsButton
@onready var _animal_box_container: VBoxContainer = %AnimalBoxContainer
@onready var _add_new_animal_button: Button = %AddNewAnimalButton

func _ready() -> void:
	assert(_date_time_edit)
	assert(_camera_options_button)
	assert(_animal_box_container)
	assert(_add_new_animal_button)

	_add_new_animal_button.pressed.connect(_add_animal_box)

func reset() -> void:
	var all_cameras: Array[FSCamera] = CommandQueryDispatcher.dispatch(FindAllCamerasQuery.new())
	_camera_options_button.clear()
	for camera in all_cameras:
		_camera_options_button.add_item(camera.name, camera._id)

	_date_time_edit.text = ""

	if _camera_options_button.item_count > 0:
		_camera_options_button.select(0)

	for animal_box in _animal_box_container.get_children():
		_animal_box_container.remove_child(animal_box)
		animal_box.queue_free()
	_add_animal_box()

func reset_to_spots(spots: Array[AnimalSpot]) -> void:
	var animal_count_map := {}
	for spot in spots:
		animal_count_map[spot.animal_name] = spot.animal_count

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

func _add_animal_box() -> void:
	_animal_box_container.add_child(_animal_box_scene.instantiate())

func create_spots() -> Array[AnimalSpot]:
	var spots: Array[AnimalSpot] = []
	for node in _animal_box_container.get_children():
		var animal_box := node as AnimalBox
		if animal_box.get_animal_name().is_empty() || animal_box.get_animal_count() <= 0:
			continue

		var spot = AnimalSpot.new()
		spot.source = "image"
		spot.spotted_at = date_time
		spot.animal_name = animal_box.get_animal_name()
		spot.animal_count = animal_box.get_animal_count()
		spot.camera_id = camera_id
		
		spots.append(spot)

	return spots
