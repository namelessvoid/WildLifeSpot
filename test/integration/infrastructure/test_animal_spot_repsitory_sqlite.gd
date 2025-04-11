extends GutTest

const Repository = preload("res://infrastructure/animal_spot_repsitory_sqlite.gd")

func _create_repository() -> AnimalSpotRepository:
	var repository := Repository.new()
	repository._db_path = ":memory:"
	add_child_autofree(repository)
	return repository

func test_find_all_returns_empty_array_if_no_spots_exist():
	var repository := _create_repository()
	
	assert_true(repository.find_all().is_empty())

func test_find_all_returns_saved_spots():
	var repository := _create_repository()
	var spot1 = AnimalSpot.new()
	var spot2 = AnimalSpot.new()
	repository.save(spot1)
	repository.save(spot2)

	assert_eq(repository.find_all().size(), 2)

func test_saves_and_restores_spot_properly():
	# Arrange
	var repository := _create_repository()
	var spot = AnimalSpot.new()
	spot.source = "image"
	spot.camera_id = 2
	spot.file_path = "/some/path/image.png"
	spot.spotted_at = "2025-04-04T14:00:12"
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
	assert_eq(spot_from_db.spotted_at, "2025-04-04T14:00:12")
	assert_eq(spot_from_db.animal_name, "Beaver")
	assert_eq(spot_from_db.animal_count, 5)

func test_find_all_by_date_returns_empty_array_if_no_spots_exist():
	var repository := _create_repository()

	assert_true(repository.find_all_by_date("2025-01-01").is_empty())

func test_find_all_by_date_returns_all_matching_spots():
	# Arrange
	var repository := _create_repository()

	var spot1 = AnimalSpot.new()
	spot1.spotted_at = "2025-01-01T15:00:12"
	repository.save(spot1)

	var spot2 = AnimalSpot.new()
	spot2.spotted_at = "2025-01-01T03:12:48"
	repository.save(spot2)

	var spot3 = AnimalSpot.new()
	spot3.spotted_at = "2025-01-02T00:00:00"
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

	var spot1 = AnimalSpot.new()
	spot1.spotted_at = "2025-01-01T15:00:12"
	repository.save(spot1)

	var spot2 = AnimalSpot.new()
	spot2.spotted_at = "2025-01-01T03:12:48"
	repository.save(spot2)

	var spot3 = AnimalSpot.new()
	spot3.spotted_at = "2025-01-02T00:00:00"
	repository.save(spot3)

	# Act
	var dates = repository.find_all_dates()

	# Assert
	assert_eq(dates, PackedStringArray(["2025-01-01", "2025-01-02"]))

func test_delete_by_source_and_spotted_at_does_only_delete_matching_spots():
	# Arrange
	var repository := _create_repository()

	var spot_non_matching_source = AnimalSpot.new()
	spot_non_matching_source.source = "not-image"
	spot_non_matching_source.spotted_at = "2025-01-01T12:01:03"
	spot_non_matching_source.animal_name = "non-matching-source"
	repository.save(spot_non_matching_source)

	var spot_non_matching_spotted_at = AnimalSpot.new()
	spot_non_matching_spotted_at.source = "image"
	spot_non_matching_spotted_at.spotted_at = "2025-01-01T12:01:04"
	spot_non_matching_spotted_at.animal_name = "non-matching-date-time"
	repository.save(spot_non_matching_spotted_at)

	var matching_spot1 := AnimalSpot.new()
	matching_spot1.source = "image"
	matching_spot1.spotted_at = "2025-01-01T12:01:03"
	repository.save(matching_spot1)

	var matching_spot2 := AnimalSpot.new()
	matching_spot2.source = "image"
	matching_spot2.spotted_at = "2025-01-01T12:01:03"
	repository.save(matching_spot2)

	# Sanity check
	assert_eq(repository.find_all().size(), 4)

	# Act
	repository.delete_by_source_and_spotted_at("image", "2025-01-01T12:01:03")

	# Assert
	var spots := repository.find_all()
	assert_eq(spots.size(), 2)
	assert_eq(spots[0].animal_name, "non-matching-source")
	assert_eq(spots[1].animal_name, "non-matching-date-time")
