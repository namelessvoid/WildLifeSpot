extends GutTest

const _bulk_spot_window_scene := preload("res://ui/spots/bulk_spot_window.tscn")
const ImagePreprocessor := preload("res://ui/spots/image_preprocessor.gd")
const CommandQueryHandlerGenerator := preload("res://test/generators/command_query_handler_generator.gd")

signal _pre_process_finished

func test_bulk_spot_window_should_update_preprocess_progress_bar():
	# Arrange
	var bulk_spot_window := _bulk_spot_window_scene.instantiate()
	bulk_spot_window.file_hasher = double(FileHasher).new()
	bulk_spot_window.spot_repository = double(AnimalSpotRepository).new()
	bulk_spot_window.processed_images_repository = double(FSProcessedImageRepository).new()

	var image_preprocessor: ImagePreprocessor = double(ImagePreprocessor).new()
	bulk_spot_window._image_preprocessor = image_preprocessor
	add_child_autofree(bulk_spot_window)

	var progress_bar: ProgressBar = bulk_spot_window.get_node("%PreprocessingProgressBar")
	assert(progress_bar)

	var mock_handler: CommandQueryHandler = CommandQueryHandlerGenerator.new()\
		.build()
	add_child_autofree(mock_handler)
	CommandQueryDispatcher._handlers = [mock_handler]

	stub(image_preprocessor, "pre_process").to_call(
		func(_file_paths: PackedStringArray, _skip_already_processed: bool, _group_by_quarters: bool):
			await _pre_process_finished
	)

	# Act & Assert
	bulk_spot_window.selected_files = ["/foo"]
	bulk_spot_window.get_node("%StartPreprocessingButton").pressed.emit()

	assert_eq(progress_bar.value, 0.0)

	image_preprocessor.progress_changed.emit(21.9)
	assert_eq(progress_bar.value, 22.0)

	image_preprocessor.progress_changed.emit(23.49)
	assert_eq(progress_bar.value, 23.0)

	image_preprocessor.progress_changed.emit(99.0)
	assert_eq(progress_bar.value, 99.0)

	image_preprocessor.progress_changed.emit(99.9)
	assert_eq(progress_bar.value, 100.0)

	image_preprocessor.progress_changed.emit(100.0)
	assert_eq(progress_bar.value, 100.0)
