extends GutTest

const _bulk_spot_window_scene: PackedScene = preload("res://ui/spots/bulk_spot_window.tscn")
const BulkSpotWindow = preload("res://ui/spots/bulk_spot_window.gd")

const CommandQueryHandlerGenerator := preload("res://test/generators/command_query_handler_generator.gd")
const ExifInfoGenerator := preload("res://test/generators/exif_info_generator.gd")

func _generate_bulk_spot_window() -> BulkSpotWindow:
	var bulk_spot_window := _bulk_spot_window_scene.instantiate()
	bulk_spot_window.camera_repository = double(FSCameraRepository).new()
	bulk_spot_window.file_hasher = double(FileHasher).new()
	bulk_spot_window.spot_repository = double(AnimalSpotRepository).new()
	bulk_spot_window.processed_images_repository = double(FSProcessedImageRepository).new()
	return bulk_spot_window

func test_shows_preprocessing_options_when_opened_with_new_files():
	var bulk_spot_window := _generate_bulk_spot_window()
	add_child_autofree(bulk_spot_window)
	bulk_spot_window.popup_centered_ratio(0.9)
	bulk_spot_window.selected_files = []

	assert_true(bulk_spot_window.get_node("%PreprocessingOptionsContainer").visible)
	assert_false(bulk_spot_window.get_node("%MainContainer").visible)
	assert_false(bulk_spot_window.get_node("%PreprocessingProgressContainer").visible)

func test_shows_main_container_when_preprocessing_finished():
	# Arrange
	var bulk_spot_window := _generate_bulk_spot_window()
	add_child_autofree(bulk_spot_window)

	stub(bulk_spot_window.camera_repository, "find_all").to_return([])

	var mock_handler: CommandQueryHandler = CommandQueryHandlerGenerator.new()\
		.with_query(ComputeImageHashQuery, "hash")\
		.with_query(HasImageBeenProcessedQuery, false)\
		.with_query(GetExifInfoQuery, { TestFixtures.image_path1: ExifInfoGenerator.new().build() } as Dictionary[String, ExifInfo])\
		.with_query(FindAllAnimalSpotsByQuery, [] as Array[AnimalSpot])\
		.build()
	add_child_autofree(mock_handler)
	CommandQueryDispatcher._handlers = [mock_handler]

	# Act
	bulk_spot_window.popup_centered_ratio(0.9)
	bulk_spot_window.selected_files = [TestFixtures.image_path1]
	bulk_spot_window.get_node("%StartPreprocessingButton").pressed.emit()

	# Assert
	assert_true(bulk_spot_window.get_node("%MainContainer").visible)
	assert_false(bulk_spot_window.get_node("%PreprocessingOptionsContainer").visible)
	assert_false(bulk_spot_window.get_node("%PreprocessingProgressContainer").visible)

func test_deletes_spots_and_saves_new_ones():
	# Arrange
	var bulk_spot_window := _generate_bulk_spot_window()
	add_child_autofree(bulk_spot_window)

	var camera := FSCamera.new()
	camera._id = 12
	stub(bulk_spot_window.camera_repository, "find_all").to_return([camera])

	var handler: CommandQueryHandler = CommandQueryHandlerGenerator.new()\
		.with_query(ComputeImageHashQuery, "hash")\
		.with_query(HasImageBeenProcessedQuery, false)\
		.with_query(GetExifInfoQuery, { TestFixtures.image_path1: ExifInfoGenerator.new().build() } as Dictionary[String, ExifInfo])\
		.with_query(FindAllAnimalSpotsByQuery, [] as Array[AnimalSpot])\
		.with_command(DeleteExistingAnimalSpots)\
		.build()
	add_child_autofree(handler)
	CommandQueryDispatcher._handlers = [handler]

	# Act
	bulk_spot_window.popup_centered_ratio(0.9)
	bulk_spot_window.selected_files = [TestFixtures.image_path1]
	bulk_spot_window.get_node("%StartPreprocessingButton").pressed.emit()

	var date_time_edit: LineEdit = bulk_spot_window.get_node("%DateTimeEdit")
	date_time_edit.text = "2025-11-02T14:15:00Z"

	var camera_options_button: OptionButton = bulk_spot_window.get_node("%CameraOptionsButton")
	camera_options_button.select(0)

	var animal_box_container: Container = bulk_spot_window.get_node("%AnimalBoxContainer")
	var animal_box := animal_box_container.get_child(0) as AnimalBox
	animal_box._name_edit.text = "Kabuto"
	animal_box._count_spin_box.value = 3

	bulk_spot_window.get_node("%SaveAndNextButton").pressed.emit()

	# Assert
	assert_called(bulk_spot_window.spot_repository, "save")
	var animal_spot: AnimalSpot = get_call_parameters(bulk_spot_window.spot_repository, "save")[0]
	assert_eq(animal_spot.animal_name, "Kabuto")
	assert_eq(animal_spot.animal_count, 3)
	assert_eq(animal_spot.spotted_at, "2025-11-02T14:15:00Z")
	assert_eq(animal_spot.source, "image")
	assert_eq(animal_spot.camera_id, 12)
