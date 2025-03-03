extends Window

const AnimalBoxScene := preload("res://ui/animal_box.tscn")

var camera_repository: FSCameraRepository
var spot_repository: FSSpotRepository
var exif_reader: ExifReader
var file_hasher: FileHasher

var directory: String:
	get: return directory
	set(value):
		directory = value
		_on_directory_changed()

@onready var _preprocessing_container: CenterContainer = %PreprocessingContainer
@onready var _preprocessing_progress: ProgressBar = %PreprocessingProgress


@onready var _main_container: HSplitContainer = %MainContainer
@onready var _image_rect: TextureRect = %ImageRect
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _date_time_edit: LineEdit = %DateTimeEdit
@onready var _temperature_edit: SpinBox = %TemperatureEdit
@onready var _camera_options_button: OptionButton = %CameraOptionsButton
@onready var _animal_box_container: VBoxContainer = %AnimalBoxContainer
@onready var _add_new_animal_button: Button = %AddNewAnimalButton
@onready var _skip_button: Button = %SkipButton
@onready var _save_and_next_button: Button = %SaveAndNextButton

var _paths: PackedStringArray
var _next_image: int

func _ready() -> void:
	assert(_main_container)
	assert(_image_rect)
	assert(_progress_bar)
	assert(_date_time_edit)
	assert(_temperature_edit)
	assert(_camera_options_button)
	assert(_animal_box_container)
	assert(_add_new_animal_button)
	assert(_skip_button)
	assert(_save_and_next_button)

	_add_new_animal_button.pressed.connect(_add_animal_box)
	_skip_button.pressed.connect(_show_next_image)
	_save_and_next_button.pressed.connect(_save_and_show_next_image)
	close_requested.connect(hide)

func _on_directory_changed() -> void:
	assert(exif_reader)
	assert(spot_repository)
	assert(camera_repository)
	assert(file_hasher)

	_main_container.visible = false
	_preprocessing_container.visible = true

	var existing_hashes: Array = spot_repository.find_all()\
		.map(func(spot: FSSpot) -> String: return spot.file_hash)

	var files := Array(DirAccess.get_files_at(directory))\
	.filter(func(file_name: String) -> bool:
		var extension = file_name.to_lower().get_extension()
		return extension == 'jpg' ||  extension == '.png'
	).map(func(file_name: String) -> Dictionary[String, Variant]:
		return { "path": directory + "/" + file_name, "already_persisted": false }
	)

	var group_id := WorkerThreadPool.add_group_task(func(index: int) -> void:
		var path: String= files[index]["path"]
		var hash = file_hasher.get_file_hash(path)
		files[index]["already_persisted"] = existing_hashes.has(hash)
	, files.size())

	_preprocessing_progress.value = 0
	if files.size() > 100:
		while !WorkerThreadPool.is_group_task_completed(group_id):
			var processed = WorkerThreadPool.get_group_processed_element_count(group_id)
			_preprocessing_progress.value = (processed / float(files.size())) * 100.0
			if processed < files.size():
				await get_tree().create_timer(1).timeout

	WorkerThreadPool.wait_for_group_task_completion(group_id)

	files = files.filter(func(f: Dictionary) -> bool:
		return !f["already_persisted"]
	)
	
	var file_paths = PackedStringArray(
		files.map(func(f) -> String: return f["path"])
	)
	
	_pre_processing_finished(file_paths)

func _pre_processing_finished(file_paths: PackedStringArray) -> void:
	if file_paths.is_empty():
		hide()
		return

	_main_container.visible = true
	_preprocessing_container.visible = false

	_camera_options_button.clear()
	for camera in camera_repository.find_all():
		_camera_options_button.add_item(camera.name, camera._id)

	_paths = file_paths
	_next_image = -1

	# Reset UI
	_date_time_edit.text = ""
	_temperature_edit.value = 0
	_camera_options_button.select(0)
	for animal_box in _animal_box_container.get_children():
		_animal_box_container.remove_child(animal_box)
		animal_box.queue_free()
	_add_animal_box()

	_show_next_image()

func _save_and_show_next_image() -> void:
	var file_path := _paths[_next_image]

	var spot := FSSpot.new()
	spot.type = "image"
	spot.file_path = file_path
	spot.file_hash = file_hasher.get_file_hash(file_path)
	spot.date_time = _date_time_edit.text
	spot.temperature = _temperature_edit.value
	spot.animals = {}
	for node in _animal_box_container.get_children():
		var animal_box := node as AnimalBox
		spot.animals[animal_box.get_animal_name()] = animal_box.get_animal_count()

	spot_repository.save(spot)

	_show_next_image()

func _show_next_image():
	_next_image += 1
	if _next_image >= _paths.size():
		hide()
		return

	var file_path := _paths[_next_image]
	var image := Image.load_from_file(file_path)
	_image_rect.texture = ImageTexture.create_from_image(image)

	var exif_info = exif_reader.get_exif_info(file_path)
	if exif_info != null:
		_date_time_edit.text = exif_info.date_time

func _add_animal_box() -> void:
	_animal_box_container.add_child(AnimalBoxScene.instantiate())
