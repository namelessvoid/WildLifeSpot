extends GutTest

const Repository = preload("res://infrastructure/animal_spot_repsitory_sqlite.gd")

const AnimalSpotGenerator = preload("res://test/generators/animal_spot_generator.gd")

func _create_repository() -> AnimalSpotRepository:
	var repository := Repository.new()
	repository.set_db_path(":memory:")
	add_child_autofree(repository)
	return repository

func test_find_all_by_returns_matching_single_spot():
	# Arrange
	var repository := _create_repository()
	var animal_spot: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(AnimalSpot.SOURCE_CAMERA_IMAGE)\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.build()
	repository.save(animal_spot)
	
	var all = repository.find_all()

	# Act
	var found_spots := repository.find_all_by(AnimalSpot.SOURCE_CAMERA_IMAGE, 12, "2024-12-01T12:00:14")

	# Assert
	assert_eq(found_spots.size(), 1)

func test_find_all_by_returns_all_matching_spots():
	# Arrange
	var repository := _create_repository()

	var animal_spot_1: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(AnimalSpot.SOURCE_CAMERA_IMAGE)\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.with_animal_name("Lion")\
		.build()
	repository.save(animal_spot_1)

	var animal_spot_2: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(AnimalSpot.SOURCE_CAMERA_IMAGE)\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.with_animal_name("Tiger")\
		.build()
	repository.save(animal_spot_2)

	# Act
	var found_spots := repository.find_all_by(AnimalSpot.SOURCE_CAMERA_IMAGE, 12, "2024-12-01T12:00:14")

	# Assert
	assert_eq(found_spots.size(), 2)
	assert_eq(found_spots[0].animal_name, "Lion")
	assert_eq(found_spots[1].animal_name, "Tiger")


var non_matching_parameters = [
	[AnimalSpot.SOURCE_CAMERA_IMAGE, 12, "2024-12-01T12:00:14", 1], # Sanity check
	[AnimalSpot.SOURCE_CAMERA_IMAGE, 13, "2024-12-01T12:00:14", 0],
	["human", 12, "2024-12-01T12:00:14", 0],
	[AnimalSpot.SOURCE_CAMERA_IMAGE, 12, "2024-12-01T12:00:15", 0]
]
func test_find_all_by_returns_empty_array_if_nothing_matches(
	params=use_parameters(non_matching_parameters)
):
	# Arrange
	var repository := _create_repository()
	var animal_spot: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(params[0])\
		.with_camera_id(params[1])\
		.with_spotted_at(params[2])\
		.build()
	repository.save(animal_spot)

	# Act
	var found_spots = repository.find_all_by(AnimalSpot.SOURCE_CAMERA_IMAGE, 12, "2024-12-01T12:00:14")

	# Assert
	assert_eq(found_spots.size(), params[3])
