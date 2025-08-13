extends GdUnitTestSuite

const ImagePreprocessor := preload("res://ui/spots/image_preprocessor.gd")
const CommandQueryHandlerGenerator := preload("res://test/generators/command_query_handler_generator.gd")

signal _pre_process_finished

func test_bulk_spot_window_should_update_preprocess_progress_bar():
	# Arrange
	var runner := scene_runner("res://ui/spots/bulk_spot_window.tscn")
	runner.set_property("camera_repository", mock(FSCameraRepository))
	runner.set_property("file_hasher", mock(FileHasher))
	runner.set_property("spot_repository", mock(AnimalSpotRepository))
	runner.set_property("processed_images_repository", mock(FSProcessedImageRepository))

	var image_preprocessor: ImagePreprocessor = mock(ImagePreprocessor)
	runner.set_property("_image_preprocessor", image_preprocessor)

	# Hack to re-init with provided mocks
	runner.invoke("_ready")

	var progress_bar: ProgressBar = runner.find_child("PreprocessingProgressBar")
	assert(progress_bar)

	var mock_handler: CommandQueryHandler = CommandQueryHandlerGenerator.new()\
		.build()
	auto_free(mock_handler)
	CommandQueryDispatcher._handlers = [mock_handler]

	#stub(image_preprocessor, "pre_process").to_call(
		#func(p_file_paths: PackedStringArray, p_skip_already_processed: bool, p_group_by_quarters: bool):
			#await _pre_process_finished
	#)
#
	## Act & Assert
	runner.set_property("selected_files", ["/foo"])
	runner.find_child("StartPreprocessingButton").pressed.emit()

	assert_float(progress_bar.value).is_equal(0.0)

	image_preprocessor.progress_changed.emit(21.9)
	assert_float(progress_bar.value).is_equal(22.0)

	image_preprocessor.progress_changed.emit(23.49)
	assert_float(progress_bar.value).is_equal(23.0)

	image_preprocessor.progress_changed.emit(99.0)
	assert_float(progress_bar.value).is_equal(99.0)

	image_preprocessor.progress_changed.emit(99.9)
	assert_float(progress_bar.value).is_equal(100.0)

	image_preprocessor.progress_changed.emit(100.0)
	assert_float(progress_bar.value).is_equal(100.0)
