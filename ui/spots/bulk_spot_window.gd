extends Window

const AnimalBoxScene := preload("res://ui/spots/animal_box.tscn")
const ImagePreprocessor := preload("res://ui/spots/image_preprocessor.gd")
const ToastBar := preload("res://ui/toast_bar.gd")

signal finished

var camera_repository: FSCameraRepository
var spot_repository: AnimalSpotRepository
var processed_images_repository: FSProcessedImageRepository
var file_hasher: FileHasher

var selected_files: PackedStringArray:
	get: return selected_files
	set(value):
		selected_files = value
		_on_selected_files_changed()

@onready var _preprocessing_options_container: Container = %PreprocessingOptionsContainer
@onready var _skip_already_processed_checkbox: CheckBox = %SkipAlreadyProcessedCheckbox
@onready var _group_into_quarters_checkbox: CheckBox = %GroupIntoQuartersCheckbox
@onready var _start_preprocessing_button: Button = %StartPreprocessingButton

@onready var _preprocessing_progress_container: Container = %PreprocessingProgressContainer
@onready var _preprocessing_progress_bar: ProgressBar = %PreprocessingProgressBar

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

@onready var _toast_bar: ToastBar = %ToastBar
@onready var _time_bucket_finished_dialog: AcceptDialog = %TimeBucketFinishedDialog

var _image_preprocessor: ImagePreprocessor

var _bucketed_file_paths: Array[Dictionary]
var _next_image: int
var _previous_time_bucket: String = ""

func _ready() -> void:
	assert(_preprocessing_options_container)
	assert(_skip_already_processed_checkbox)
	assert(_start_preprocessing_button)
	assert(_group_into_quarters_checkbox)
	assert(_preprocessing_progress_container)
	assert(_preprocessing_progress_bar)

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
	assert(_toast_bar)
	assert(_time_bucket_finished_dialog)

	_start_preprocessing_button.pressed.connect(_pre_process)

	# We don't use @onready to make the _image_preprocessor stubbable for tests.
	if _image_preprocessor == null:
		_image_preprocessor = %ImagePreprocessor
	_image_preprocessor.progress_changed.connect(_on_image_preprocessor_progress_changed)

	_add_new_animal_button.pressed.connect(_add_animal_box)
	_back_button.pressed.connect(_show_previous_image)
	_skip_button.pressed.connect(_show_next_image)
	_save_and_next_button.pressed.connect(_save_and_show_next_image)
	_image_viewer.request_save_image.connect(_on_image_viewer_save_image_requested)

	_time_bucket_finished_dialog.close_requested.connect(_on_time_bucket_finished_dialog_closed)
	_time_bucket_finished_dialog.confirmed.connect(_on_time_bucket_finished_dialog_closed)
	_time_bucket_finished_dialog.canceled.connect(_on_time_bucket_finished_dialog_closed)
	_time_bucket_finished_dialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_bucket_finished_dialog.get_label().vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	close_requested.connect(hide)

func _on_selected_files_changed() -> void:
	assert(spot_repository)
	assert(camera_repository)
	assert(processed_images_repository)
	assert(file_hasher)

	_show_preprocessing_options()

func _on_image_preprocessor_progress_changed(p_value: float) -> void:
	_preprocessing_progress_bar.value = p_value

func _show_preprocessing_options():
	_main_container.visible = false
	_preprocessing_options_container.visible = true
	_preprocessing_progress_container.visible = false

func _pre_process() -> void:
	_preprocessing_options_container.visible = false
	_preprocessing_progress_container.visible = true

	var skip_processed_files := _skip_already_processed_checkbox.button_pressed
	var group_into_quarters := _group_into_quarters_checkbox.button_pressed
	var file_paths_with_time_bucket := await _image_preprocessor.pre_process(
		selected_files, skip_processed_files, group_into_quarters
	)
	_pre_processing_finished(file_paths_with_time_bucket)

func _pre_processing_finished(p_bucketed_file_paths: Array[Dictionary]) -> void:
	if p_bucketed_file_paths.is_empty():
		hide()
		return

	_main_container.visible = true
	_preprocessing_options_container.visible = false
	_preprocessing_progress_container.visible = false

	_progress_bar.value = 0
	_progress_bar.max_value = p_bucketed_file_paths.size()
	_progress_label.text = "%d / %d" % [1, _progress_bar.max_value]

	_camera_options_button.clear()
	for camera in camera_repository.find_all():
		_camera_options_button.add_item(camera.name, camera._id)

	_bucketed_file_paths = p_bucketed_file_paths
	_next_image = -1

	# Reset UI
	_date_time_edit.text = ""
	_temperature_edit.value = 0

	if _camera_options_button.item_count > 0:
		_camera_options_button.select(0)

	for animal_box in _animal_box_container.get_children():
		_animal_box_container.remove_child(animal_box)
		animal_box.queue_free()
	_add_animal_box()

	_show_next_image()

func _save_and_show_next_image() -> void:
	var file_path: Dictionary = _bucketed_file_paths[_next_image]
	var spot_date_time = _date_time_edit.text
	var camera_id := _camera_options_button.get_item_id(_camera_options_button.selected)
	
	var command := DeleteExistingAnimalSpots.new(
		"image",
		spot_date_time
	)
	CommandQueryDispatcher.dispatch(command)

	for node in _animal_box_container.get_children():
		var animal_box := node as AnimalBox
		if animal_box.get_animal_name().is_empty() || animal_box.get_animal_count() <= 0:
			continue

		var spot = AnimalSpot.new()
		spot.source = "image"
		spot.file_path = file_path["file_path"]
		spot.spotted_at = spot_date_time
		spot.animal_name = animal_box.get_animal_name()
		spot.animal_count = animal_box.get_animal_count()
		spot.camera_id = camera_id

		spot_repository.save(spot)

	var file_hash = file_hasher.get_file_hash(file_path["file_path"])
	processed_images_repository.mark_processed(file_hash)

	_show_next_image()

func _show_previous_image():
	_next_image -= 1
	if _next_image < 0:
		_next_image = 0

	_update_ui()

func _show_next_image():
	_next_image += 1
	if _next_image >= _bucketed_file_paths.size():
		finished.emit()
		hide()
		return

	_update_ui()

func _update_ui():
	_progress_bar.value = _next_image
	_progress_label.text = "%d / %d" % [_progress_bar.value + 1, _progress_bar.max_value]

	var file_path := _bucketed_file_paths[_next_image]
	var image := Image.load_from_file(file_path["file_path"])
	var time_bucket: String = Time.get_datetime_string_from_unix_time(file_path["bucket"])
	_image_viewer.set_texture.call_deferred(ImageTexture.create_from_image(image))
	_date_time_edit.text = time_bucket

	# Update animal inputs if image has been spotted before
	var camera_id := _camera_options_button.get_item_id(_camera_options_button.selected)
	var spotted_at := _date_time_edit.text
	var query := FindAllAnimalSpotsByQuery.new("image", camera_id, spotted_at)
	var existing_spots: Array[AnimalSpot] = CommandQueryDispatcher.dispatch(query)
	if existing_spots.size() > 0:
		var animal_count_map := {}
		for spot in existing_spots:
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
	elif  _group_into_quarters_checkbox.button_pressed \
			&& !_previous_time_bucket.is_empty() \
			&& _previous_time_bucket != time_bucket:
		_set_animal_box_counts_to_zero()
	_previous_time_bucket = time_bucket

func _add_animal_box() -> void:
	_animal_box_container.add_child(AnimalBoxScene.instantiate())

func _set_animal_box_counts_to_zero() -> void:
	for box_node in _animal_box_container.get_children():
		var animal_box: AnimalBox = box_node
		animal_box.set_animal_count(0)
	_show_time_bucket_finished_dialog()

func _show_time_bucket_finished_dialog():
	_time_bucket_finished_dialog.popup_centered()
	unfocusable = true

func _on_time_bucket_finished_dialog_closed():
	unfocusable = false
	grab_focus()

func _on_image_viewer_save_image_requested():
	var file: String = _bucketed_file_paths[_next_image]["file_path"].get_file()
	var dir = ProjectSettings.globalize_path(
		Settings.get_setting(Settings.IMAGE_STORE, Settings.IMAGE_STORE_PATH)
	)
	FileDialogManager.show_file_save_dialog(_save_image, file, dir)

func _save_image(p_target_path: String) -> void:
	var file_to_save: String = _bucketed_file_paths[_next_image]["file_path"]
	var bytes := FileAccess.get_file_as_bytes(file_to_save)
	var target_file := FileAccess.open(p_target_path, FileAccess.WRITE)
	if !target_file:
		return
	target_file.store_buffer(bytes)
	target_file.close()
