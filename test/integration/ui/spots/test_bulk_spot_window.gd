extends GdUnitTestSuite

const _bulk_spot_window_scene: PackedScene = preload("res://ui/spots/bulk_spot_window.tscn")
const BulkSpotWindow = preload("res://ui/spots/bulk_spot_window.gd")

const CommandQueryHandlerGenerator := preload("res://test/generators/command_query_handler_generator.gd")
const ExifInfoGenerator := preload("res://test/generators/exif_info_generator.gd")

func _generate_bulk_spot_window() -> BulkSpotWindow:
	var bulk_spot_window := _bulk_spot_window_scene.instantiate()
	bulk_spot_window.camera_repository = mock(FSCameraRepository)
	bulk_spot_window.file_hasher = mock(FileHasher)
	bulk_spot_window.spot_repository = mock(AnimalSpotRepository)
	bulk_spot_window.processed_images_repository = mock(FSProcessedImageRepository)
	return bulk_spot_window

func test_shows_preprocessing_options_when_opened_with_new_files():
	var runner := scene_runner(_generate_bulk_spot_window())
	runner.invoke("popup_centered_ratio", 0.9)
	runner.set_property("selected_files", [])

	assert_bool(runner.find_child("PreprocessingOptionsContainer").visible).is_true()
	assert_bool(runner.find_child("MainContainer").visible).is_false()
	assert_bool(runner.find_child("PreprocessingProgressContainer").visible).is_false()

func test_shows_main_container_when_preprocessing_finished():
	# Arrange
	var bulk_spot_window := _generate_bulk_spot_window()
	var runner := scene_runner(bulk_spot_window)

	do_return([]).on(bulk_spot_window.camera_repository).find_all()
	
	var image_file_path := ProjectSettings.globalize_path("res://test/integration/infrastructure/fixtures/fixture_image1.jpg")

	var mock_handler: CommandQueryHandler = CommandQueryHandlerGenerator.new()\
		.with_query(ComputeImageHashQuery, "hash")\
		.with_query(HasImageBeenProcessedQuery, false)\
		.with_query(GetExifInfoQuery, { image_file_path: ExifInfoGenerator.new().build() } as Dictionary[String, ExifInfo])\
		.with_query(FindAllAnimalSpotsByQuery, [] as Array[AnimalSpot])\
		.build()
	auto_free(mock_handler)
	CommandQueryDispatcher._handlers = [mock_handler]

	# Act
	bulk_spot_window.popup_centered_ratio(0.9)
	bulk_spot_window.selected_files = [image_file_path]
	bulk_spot_window.get_node("%StartPreprocessingButton").pressed.emit()

	# Assert
	assert_bool(bulk_spot_window.get_node("%MainContainer").visible).is_true()
	assert_bool(bulk_spot_window.get_node("%PreprocessingOptionsContainer").visible).is_false
	assert_bool(bulk_spot_window.get_node("%PreprocessingProgressContainer").visible).is_false

func test_deletes_spots_and_saves_new_ones():
	# Arrange
	var bulk_spot_window := _generate_bulk_spot_window()
	var runner := scene_runner(bulk_spot_window)

	var camera := FSCamera.new()
	camera._id = 12
	do_return([camera]).on(bulk_spot_window.camera_repository).find_all()
	
	var image_file_path := ProjectSettings.globalize_path("res://test/integration/infrastructure/fixtures/fixture_image1.jpg")

	var handler: CommandQueryHandler = CommandQueryHandlerGenerator.new()\
		.with_query(ComputeImageHashQuery, "hash")\
		.with_query(HasImageBeenProcessedQuery, false)\
		.with_query(GetExifInfoQuery, { image_file_path: ExifInfoGenerator.new().build() } as Dictionary[String, ExifInfo])\
		.with_query(FindAllAnimalSpotsByQuery, [] as Array[AnimalSpot])\
		.with_command(DeleteExistingAnimalSpots)\
		.build()
	auto_free(handler)
	CommandQueryDispatcher._handlers = [handler]

	# Act
	bulk_spot_window.popup_centered_ratio(0.9)
	bulk_spot_window.selected_files = [image_file_path]
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
	verify(bulk_spot_window.spot_repository, 1).save(AnimalSpotMatcher.new(func(actual: Variant) -> bool:
		var actual_animal_spot := actual as AnimalSpot
		assert_str(actual_animal_spot.animal_name).is_equal("Kabuto")
		assert_int(actual_animal_spot.animal_count).is_equal(3)
		assert_str(actual_animal_spot.spotted_at).is_equal("2025-11-02T14:15:00Z")
		assert_str(actual_animal_spot.source).is_equal("image")
		assert_int(actual_animal_spot.camera_id).is_equal(12)
		return true
	))


class AnimalSpotMatcher extends GdUnitArgumentMatcher:
	var _compare_func: Callable
	
	func _init(p_compare_func: Callable):
		_compare_func = p_compare_func

	func is_match(actual_value: Variant) -> bool:
		return _compare_func.call(actual_value)
