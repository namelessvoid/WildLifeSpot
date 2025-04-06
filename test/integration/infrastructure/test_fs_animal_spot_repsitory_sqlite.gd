extends GutTest

const Repository = preload("res://infrastructure/fs_animal_spot_repsitory_sqlite.gd")

func _create_repository() -> FSAnimalSpotRepository:
	var repository := Repository.new()
	repository._db_path = ":memory:"
	add_child_autofree(repository)
	return repository

func test_find_all_returns_empty_array_if_no_spots_exist():
	var repository := _create_repository()
	
	assert_true(repository.find_all().is_empty())

func test_find_all_returns_saved_spots():
	var repository := _create_repository()
	var spot1 = FSAnimalSpot.new()
	var spot2 = FSAnimalSpot.new()
	repository.save(spot1)
	repository.save(spot2)

	assert_eq(repository.find_all().size(), 2)

func test_saves_and_restores_spot_properly():
	# Arrange
	var repository := _create_repository()
	var spot = FSAnimalSpot.new()
	spot.source = "image"
	spot.camera_id = 2
	spot.file_path = "/some/path/image.png"
	spot.date_time = "2025-04-04T14:00:12"
	spot.animal_name = "Beaver"
	spot.animal_count = 5

	# Act
	repository.save(spot)
	var spot_from_db := repository.find_all()[0]

	# Assert
	assert_eq(spot_from_db._id, 1)
	assert_eq(spot_from_db.source, "image")
	assert_eq(spot_from_db.camera_id, 2)
	assert_eq(spot_from_db.file_path, "/some/path/image.png")
	assert_eq(spot_from_db.date_time, "2025-04-04T14:00:12")
	assert_eq(spot_from_db.animal_name, "Beaver")
	assert_eq(spot_from_db.animal_count, 5)

func test_find_all_by_date_returns_empty_array_if_no_spots_exist():
	var repository := _create_repository()

	assert_true(repository.find_all_by_date("2025-01-01").is_empty())

func test_find_all_by_date_returns_all_matching_spots():
	# Arrange
	var repository := _create_repository()

	var spot1 = FSAnimalSpot.new()
	spot1.date_time = "2025-01-01T15:00:12"
	repository.save(spot1)

	var spot2 = FSAnimalSpot.new()
	spot2.date_time = "2025-01-01T03:12:48"
	repository.save(spot2)

	var spot3 = FSAnimalSpot.new()
	spot3.date_time = "2025-01-02T00:00:00"
	repository.save(spot3)

	# Act
	var spots := repository.find_all_by_date("2025-01-01")

	# Assert
	assert_eq(spots.size(), 2)

func test_find_all_dates_returns_empty_array_if_no_spots_exist():
	var repository := _create_repository()
	
	assert_true(repository.find_all_dates().is_empty())

func test_find_all_dates_returns_distinct_dates():
	# Arrange
	var repository := _create_repository()

	var spot1 = FSAnimalSpot.new()
	spot1.date_time = "2025-01-01T15:00:12"
	repository.save(spot1)

	var spot2 = FSAnimalSpot.new()
	spot2.date_time = "2025-01-01T03:12:48"
	repository.save(spot2)

	var spot3 = FSAnimalSpot.new()
	spot3.date_time = "2025-01-02T00:00:00"
	repository.save(spot3)

	# Act
	var dates = repository.find_all_dates()

	# Assert
	assert_eq(dates, PackedStringArray(["2025-01-01", "2025-01-02"]))
