extends GutTest

const _bulk_spot_window_scene: PackedScene = preload("res://ui/spots/bulk_spot_window.tscn")
const BulkSpotWindow = preload("res://ui/spots/bulk_spot_window.gd")

func _generate_bulk_spot_window() -> BulkSpotWindow:
	var bulk_spot_window := _bulk_spot_window_scene.instantiate()
	bulk_spot_window.exif_reader = double(ExifReader).new()
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
	var bulk_spot_window := _generate_bulk_spot_window()
	add_child_autofree(bulk_spot_window)
	bulk_spot_window.popup_centered_ratio(0.9)
	bulk_spot_window.selected_files = ["/some/file"]

	stub(bulk_spot_window.camera_repository, "find_all").to_return([])
	bulk_spot_window.get_node("%StartPreprocessingButton").pressed.emit()

	assert_true(bulk_spot_window.get_node("%MainContainer").visible)
	assert_false(bulk_spot_window.get_node("%PreprocessingOptionsContainer").visible)
	assert_false(bulk_spot_window.get_node("%PreprocessingProgressContainer").visible)
