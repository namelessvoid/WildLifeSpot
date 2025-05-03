extends CommandQueryHandler

@export var repository: FSCameraRepository

func can_handle(dispatchable: Variant) -> bool:
	return dispatchable is CreateCameraCommand \
		|| dispatchable is UpdateCameraCommand \
		|| dispatchable is DeleteCameraCommand \
		|| dispatchable is FindAllCamerasQuery

func handle(dispatchable: Variant) -> Variant:
	if dispatchable is CreateCameraCommand:
		var camera = FSCamera.new()
		repository.save(camera)
		return camera

	if dispatchable is UpdateCameraCommand:
		var camera = FSCamera.new()
		camera._id = dispatchable._id
		camera.name = dispatchable._name
		camera.manufacturer = dispatchable._manufacturer
		camera.model = dispatchable._model
		repository.save(camera)
		return camera
	
	if dispatchable is DeleteCameraCommand:
		repository.delete(dispatchable._id)
		return null

	if dispatchable is FindAllCamerasQuery:
		return repository.find_all()

	return null
