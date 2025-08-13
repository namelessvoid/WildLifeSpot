extends GdUnitTestSuite

const Repository = preload("res://infrastructure/animal_spot_repsitory_sqlite.gd")

const AnimalSpotGenerator = preload("res://test/generators/animal_spot_generator.gd")

func _create_repository() -> AnimalSpotRepository:
	var repository: AnimalSpotRepository = auto_free(Repository.new())
	repository.set_db_path(":memory:")
	return repository

func test_find_all_by_returns_matching_single_spot():
	# Arrange
	var repository := _create_repository()
	var animal_spot: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source("image")\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.build()
	repository.save(animal_spot)
	
	var all = repository.find_all()

	# Act
	var found_spots := repository.find_all_by("image", 12, "2024-12-01T12:00:14")

	# Assert
	assert_array(found_spots).has_size(1)

func test_find_all_by_returns_all_matching_spots():
	# Arrange
	var repository := _create_repository()

	var animal_spot_1: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source("image")\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.with_animal_name("Lion")\
		.build()
	repository.save(animal_spot_1)

	var animal_spot_2: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source("image")\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.with_animal_name("Tiger")\
		.build()
	repository.save(animal_spot_2)

	# Act
	var found_spots := repository.find_all_by("image", 12, "2024-12-01T12:00:14")

	# Assert
	assert_array(found_spots).has_size(2)
	assert_str(found_spots[0].animal_name).is_equal("Lion")
	assert_str(found_spots[1].animal_name).is_equal("Tiger")


var non_matching_parameters = [
	["image", 12, "2024-12-01T12:00:14", 1], # Sanity check
	["image", 13, "2024-12-01T12:00:14", 0],
	["human", 12, "2024-12-01T12:00:14", 0],
	["image", 12, "2024-12-01T12:00:15", 0]
]
func test_find_all_by_returns_empty_array_if_nothing_matches(
	source: String,
	camera_id: int,
	spotted_at: String,
	expected_result_size: int,
	test_parameters:=[
		["image", 12, "2024-12-01T12:00:14", 1], # Sanity check
		["image", 13, "2024-12-01T12:00:14", 0],
		["human", 12, "2024-12-01T12:00:14", 0],
		["image", 12, "2024-12-01T12:00:15", 0]
	]
):
	# Arrange
	var repository := _create_repository()
	var animal_spot: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(source)\
		.with_camera_id(camera_id)\
		.with_spotted_at(spotted_at)\
		.build()
	repository.save(animal_spot)

	# Act
	var found_spots = repository.find_all_by("image", 12, "2024-12-01T12:00:14")

	# Assert
	assert_array(found_spots).has_size(expected_result_size)
