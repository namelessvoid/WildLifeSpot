extends GutTest

var test_returns_exif_info_of_single_image_data = [
	[TestFixtures.image_path1, "2025-10-24T13:20:50", "Manufacturer 1"],
	[TestFixtures.image_path2, "2024-08-01T01:02:03", "Manufacturer 2"],
	[TestFixtures.image_path3, "", ""]
]
func test_returns_exif_info_if_single_image_provided(params=use_parameters(test_returns_exif_info_of_single_image_data)):
	# Arrange
	var image_file_path: String = params[0]
	var expected_date_time: String = params[1]
	var expected_camera_make: String = params[2]

	var exif_reader := ExifReader.new()
	add_child_autofree(exif_reader)

	## Act
	var exif_infos := exif_reader.GetExifInfo([image_file_path])
#
	## Assert
	assert_eq(exif_infos.size(), 1)
	assert_eq(exif_infos[image_file_path].DateTime, expected_date_time)
	assert_eq(exif_infos[image_file_path].CameraMake, expected_camera_make)

func test_returns_all_exif_info_if_multiple_images_provided():
	# Arrange
	var exif_reader := ExifReader.new()
	add_child_autofree(exif_reader)

	# Act
	var exif_infos := exif_reader.GetExifInfo([TestFixtures.image_path1, TestFixtures.image_path2])

	# Assert
	assert_eq(exif_infos.size(), 2)
	assert_eq(exif_infos[TestFixtures.image_path1].CameraMake, "Manufacturer 1")
	assert_eq(exif_infos[TestFixtures.image_path2].CameraMake, "Manufacturer 2")
