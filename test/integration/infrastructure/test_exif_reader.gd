extends GdUnitTestSuite

var image_path1 := ProjectSettings.globalize_path("res://test/integration/infrastructure/fixtures/fixture_image1.jpg")
var image_path2 := ProjectSettings.globalize_path("res://test/integration/infrastructure/fixtures/fixture_image2.jpg")

func test_returns_exif_info_if_single_image_provided(
	image_file_path: String,
	expected_date_time: String,
	expected_camera_make: String,
	test_parameters:=[
		[image_path1, "2025-10-24T13:20:50", "Manufacturer 1"],
		[image_path2, "2024-08-01T01:02:03", "Manufacturer 2"]
	]
):
	# Arrange
	var exif_reader: ExifReader = auto_free(ExifReader.new())

	## Act
	var exif_infos: Dictionary= exif_reader.GetExifInfo([image_file_path])
#
	## Assert
	assert_dict(exif_infos).has_size(1)
	assert_str(exif_infos[image_file_path].DateTime).is_equal(expected_date_time)
	assert_str(exif_infos[image_file_path].CameraMake).is_equal(expected_camera_make)

func test_returns_all_exif_info_if_multiple_images_provided():
	# Arrange
	var exif_reader: ExifReader = auto_free(ExifReader.new())

	# Act
	var exif_infos: Dictionary = exif_reader.GetExifInfo([image_path1, image_path2])

	# Assert
	assert_dict(exif_infos).has_size(2)
	assert_str(exif_infos[image_path1].CameraMake).is_equal("Manufacturer 1")
	assert_str(exif_infos[image_path2].CameraMake).is_equal("Manufacturer 2")
