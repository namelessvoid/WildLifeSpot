extends Window

const AnimalBoxScene := preload("res://ui/animal_box.tscn")

signal finished

var camera_repository: FSCameraRepository
var spot_repository: FSSpotRepository
var exif_reader: ExifReader
var file_hasher: FileHasher

var selected_files: PackedStringArray:
	get: return selected_files
	set(value):
		selected_files = value
		_on_selected_files_changed()

@onready var _preprocessing_options_container: Container = %PreprocessingOptionsContainer
@onready var _skip_already_processed_checkbox: CheckBox = %SkipAlreadyProcessedCheckbox
@onready var _start_preproocessing_button: Button = %StartPreproocessingButton

@onready var _preprocessing_progress_container: Container = %PreprocessingProgressContainer
@onready var _preprocessing_progress: ProgressBar = %PreprocessingProgress

@onready var _main_container: Container = %MainContainer
@onready var _image_viewer: ImageViewer = %ImageViewer

@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _progress_label: Label = %ProgressLabel

@onready var _date_time_edit: LineEdit = %DateTimeEdit
@onready var _temperature_edit: SpinBox = %TemperatureEdit
@onready var _camera_options_button: OptionButton = %CameraOptionsButton
@onready var _animal_box_container: VBoxContainer = %AnimalBoxContainer
@onready var _add_new_animal_button: Button = %AddNewAnimalButton
@onready var _back_button: Button = %BackButton
@onready var _skip_button: Button = %SkipButton
@onready var _save_and_next_button: Button = %SaveAndNextButton

@onready var _save_file_dialog: FileDialog = $SaveFileDialog

var _paths: PackedStringArray
var _next_image: int

func _ready() -> void:
	assert(_preprocessing_options_container)
	assert(_skip_already_processed_checkbox)
	assert(_start_preproocessing_button)
	assert(_preprocessing_progress_container)
	assert(_preprocessing_progress)

	assert(_main_container)
	assert(_image_viewer)
	assert(_progress_bar)
	assert(_date_time_edit)
	assert(_temperature_edit)
	assert(_camera_options_button)
	assert(_animal_box_container)
	assert(_add_new_animal_button)
	assert(_back_button)
	assert(_skip_button)
	assert(_save_and_next_button)

	_start_preproocessing_button.pressed.connect(_pre_process)

	_add_new_animal_button.pressed.connect(_add_animal_box)
	_back_button.pressed.connect(_show_previous_image)
	_skip_button.pressed.connect(_show_next_image)
	_save_and_next_button.pressed.connect(_save_and_show_next_image)
	_image_viewer.request_save_image.connect(_save_image)
	close_requested.connect(hide)

func _on_selected_files_changed() -> void:
	assert(exif_reader)
	assert(spot_repository)
	assert(camera_repository)
	assert(file_hasher)

	_show_preprocessing_options()

func _show_preprocessing_options():
	_main_container.visible = false
	_preprocessing_options_container.visible = true
	_preprocessing_progress_container.visible = false

func _pre_process() -> void:
	if !_skip_already_processed_checkbox.button_pressed:
		_pre_processing_finished(selected_files)
		return

	_main_container.visible = false
	_preprocessing_options_container.visible = false
	_preprocessing_progress_container.visible = true

	var existing_hashes: Array = spot_repository.find_all()\
		.map(func(spot: FSSpot) -> String: return spot.file_hash)
	var files := Array(selected_files)\
	.map(func(path: String) -> Dictionary[String, Variant]:
		return { "path": path, "already_persisted": false }
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
	_preprocessing_options_container.visible = false
	_preprocessing_progress_container.visible = false

	_progress_bar.value = 0
	_progress_bar.max_value = file_paths.size()
	_progress_label.text = "%d / %d" % [1, _progress_bar.max_value]

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
		var name := animal_box.get_animal_name()
		var count := animal_box.get_animal_count()
		if name.is_empty() || count <= 0:
			continue
		spot.animals[animal_box.get_animal_name()] = animal_box.get_animal_count()

	spot_repository.save(spot)

	_show_next_image()

func _show_previous_image():
	_next_image -= 1
	if _next_image < 0:
		_next_image = 0

	_update_ui()

func _show_next_image():
	_next_image += 1
	if _next_image >= _paths.size():
		finished.emit()
		hide()
		return

	_update_ui()

func _update_ui():
	_progress_bar.value = _next_image
	_progress_label.text = "%d / %d" % [_progress_bar.value + 1, _progress_bar.max_value]

	var file_path := _paths[_next_image]
	var image := Image.load_from_file(file_path)
	_image_viewer.set_texture.call_deferred(ImageTexture.create_from_image(image))

	var exif_info = exif_reader.get_exif_info(file_path)
	if exif_info != null:
		_date_time_edit.text = exif_info.date_time

func _add_animal_box() -> void:
	_animal_box_container.add_child(AnimalBoxScene.instantiate())

func _save_image() -> void:
	var file_to_save := _paths[_next_image]
	_save_file_dialog.current_file = file_to_save.get_file()
	_save_file_dialog.show()
	var target_path = await _save_file_dialog.file_selected
	var bytes := FileAccess.get_file_as_bytes(file_to_save)
	var target_file := FileAccess.open(target_path, FileAccess.WRITE)
	if !target_file:
		return
	target_file.store_buffer(bytes)
	target_file.close()
