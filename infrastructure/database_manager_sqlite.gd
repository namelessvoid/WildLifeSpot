extends Node

@export var animal_spot_repository: AnimalSpotRepositorySQLite
@export var camera_repository: CameraRepositorySQLite
@export var processed_image_repository: ProcessedImageRepositorySQLite

var _db_path = &"user://wildlifespot.db"

func set_db_path(p_db_path: String):
	_db_path = p_db_path
	animal_spot_repository.set_db_path(_db_path)
	camera_repository.set_db_path(_db_path)
	processed_image_repository.set_db_path(_db_path)

func _ready():
	assert(animal_spot_repository)
	assert(camera_repository)
	assert(processed_image_repository)

	set_db_path(_db_path)
