extends Node
class_name DatabaseManagerSQLite

@export var animal_spot_repository: AnimalSpotRepositorySQLite
@export var camera_repository: CameraRepositorySQLite
@export var processed_image_repository: ProcessedImageRepositorySQLite

@export var animal_spot_repository_ef: AnimalRepository

var _db_path = &"user://wildlifespot.db"

func set_db_path(p_db_path: String):
	_db_path = p_db_path
	animal_spot_repository.set_db_path(_db_path)
	camera_repository.set_db_path(_db_path)
	processed_image_repository.set_db_path(_db_path)

	animal_spot_repository_ef.SetDbPath(
		ProjectSettings.globalize_path(p_db_path)
	)
	print(animal_spot_repository_ef.FindAllDates())

	GlobalSignals.database_changed.emit()

func _ready():
	assert(animal_spot_repository)
	assert(camera_repository)
	assert(processed_image_repository)

	set_db_path(_db_path)
