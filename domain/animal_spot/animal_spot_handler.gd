extends CommandQueryHandler

@export var repository: AnimalSpotRepository

func _ready():
	assert(repository)

func can_handle(dispatchable: Variant) -> bool:
	return dispatchable is CreateAnimalSpotCommand \
		|| dispatchable is DeleteExistingAnimalSpots \
		|| dispatchable is FindAllAnimalSpotDatesQuery \
		|| dispatchable is FindAllAnimalSpotsByQuery \
		|| dispatchable is FindAllAnimalSpotsByDateQuery \
		|| dispatchable is FindAllAnimalSpotAnimalNamesQuery

func handle(dispatchable: Variant) -> Variant:
	if dispatchable is CreateAnimalSpotCommand:
		repository.Save(dispatchable._spot)
	elif dispatchable is DeleteExistingAnimalSpots:
		repository.DeleteBySourceAndSpottedAt(dispatchable._source, dispatchable._spotted_at)
	elif dispatchable is FindAllAnimalSpotDatesQuery:
		return repository.FindAllDates()
	elif dispatchable is FindAllAnimalSpotsByQuery:
		return repository.FindAllBy(dispatchable._source, dispatchable._camera_id, dispatchable._spotted_at)
	elif dispatchable is FindAllAnimalSpotsByDateQuery:
		return repository.FindAllByDate(dispatchable._date)
	elif dispatchable is FindAllAnimalSpotAnimalNamesQuery:
		return repository.FindAllDistinctAnimalNames()

	return null
