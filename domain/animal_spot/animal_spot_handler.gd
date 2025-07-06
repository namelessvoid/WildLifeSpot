extends CommandQueryHandler

@export var repository: AnimalSpotRepository

func can_handle(dispatchable: Variant) -> bool:
	return dispatchable is DeleteExistingAnimalSpots

func handle(dispatchable: Variant) -> Variant:
	if dispatchable is DeleteExistingAnimalSpots:
		repository.delete_by_source_and_spotted_at(dispatchable._source, dispatchable._spotted_at)

	return null
