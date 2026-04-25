extends GutTest

const AnimalSpotGenerator = preload("res://test/generators/animal_spot_generator.gd")

func _create_repository() -> AnimalSpotRepository:
	var db_path = "/tmp/" + str(ResourceUID.create_id()) + ".db"
	add_child_autofree(DatabaseManagerSQLite.new()).SetDbPath(db_path)

	var repository := AnimalSpotRepository.new()
	repository.SetDbPath(db_path)
	add_child_autofree(repository)
	return repository

func test_find_all_by_returns_matching_single_spot():
	# Arrange
	var repository := _create_repository()
	var animal_spot: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(AnimalSpot.SourceCameraImage())\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.build()
	repository.Save(animal_spot)
	
	# Act
	var found_spots := repository.FindAllBy(AnimalSpot.SourceCameraImage(), 12, "2024-12-01T12:00:14")

	# Assert
	assert_eq(found_spots.size(), 1)

func test_find_all_by_returns_all_matching_spots():
	# Arrange
	var repository := _create_repository()

	var animal_spot_1: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(AnimalSpot.SourceCameraImage())\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.with_animal_name("Lion")\
		.build()
	repository.Save(animal_spot_1)

	var animal_spot_2: AnimalSpot = AnimalSpotGenerator.new()\
		.with_source(AnimalSpot.SourceCameraImage())\
		.with_camera_id(12)\
		.with_spotted_at("2024-12-01T12:00:14")\
		.with_animal_name("Tiger")\
		.build()
	repository.Save(animal_spot_2)

	# Act
	var found_spots := repository.FindAllBy(AnimalSpot.SourceCameraImage(), 12, "2024-12-01T12:00:14")

	# Assert
	assert_eq(found_spots.size(), 2)
	assert_eq(found_spots[0].AnimalName, "Lion")
	assert_eq(found_spots[1].AnimalName, "Tiger")


var non_matching_parameters = [
	[AnimalSpot.SourceCameraImage(), 12, "2024-12-01T12:00:14", 1], # Sanity check
	[AnimalSpot.SourceCameraImage(), 13, "2024-12-01T12:00:14", 0],
	["human", 12, "2024-12-01T12:00:14", 0],
	[AnimalSpot.SourceCameraImage(), 12, "2024-12-01T12:00:15", 0]
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
	repository.Save(animal_spot)

	# Act
	var found_spots = repository.FindAllBy(AnimalSpot.SourceCameraImage(), 12, "2024-12-01T12:00:14")

	# Assert
	assert_eq(found_spots.size(), params[3])
