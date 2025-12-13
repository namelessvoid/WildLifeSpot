extends GutTest

const AnimalSpotGenerator = preload("res://test/generators/animal_spot_generator.gd")

func _create_repository() -> AnimalRepository:
	var repository := AnimalRepository.new()
	repository.SetDbPath("/tmp/" + str(ResourceUID.create_id()) + ".db")
	add_child_autofree(repository)
	return repository

func test_returns_all_distinct_animal_names():
	# Arrange
	var repository := _create_repository()

	var spot1: AnimalSpot = AnimalSpotGenerator.new().with_animal_name("Foobird").build()
	var spot2: AnimalSpot = AnimalSpotGenerator.new().with_animal_name("Foobird").build()
	var spot3: AnimalSpot = AnimalSpotGenerator.new().with_animal_name("Bazbear").build()

	repository.Save(spot1)
	repository.Save(spot2)
	repository.Save(spot3)

	# Act
	var animal_names := repository.FindAllDistinctAnimalNames()

	# Assert
	assert_eq(animal_names.size(), 2)
	assert_eq(animal_names[0], "Foobird")
	assert_eq(animal_names[1], "Bazbear")

func test_returns_empty_list_if_no_spots_exist():
	# Arrange
	var repository := _create_repository()

	# Act
	var animal_names = repository.FindAllDistinctAnimalNames()

	# Assert
	print(animal_names)
	assert_true(animal_names.is_empty())
