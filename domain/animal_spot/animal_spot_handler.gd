extends CommandQueryHandler

@export var repository: AnimalSpotRepository

func can_handle(dispatchable: Variant) -> bool:
	return dispatchable is DeleteExistingAnimalSpots \
		|| dispatchable is FindAllAnimalSpotDatesQuery \
		|| dispatchable is FindAllAnimalSpotsByQuery \
		|| dispatchable is FindAllAnimalSpotsByDateQuery \
		|| dispatchable is FindAllAnimalSpotAnimalNamesQuery

func handle(dispatchable: Variant) -> Variant:
	if dispatchable is DeleteExistingAnimalSpots:
		repository.delete_by_source_and_spotted_at(dispatchable._source, dispatchable._spotted_at)
	elif dispatchable is FindAllAnimalSpotDatesQuery:
		return repository.find_all_dates()
	elif dispatchable is FindAllAnimalSpotsByQuery:
		return repository.find_all_by(dispatchable._source, dispatchable._camera_id, dispatchable._spotted_at)
	elif dispatchable is FindAllAnimalSpotsByDateQuery:
		return repository.find_all_by_date(dispatchable._date)
	elif dispatchable is FindAllAnimalSpotAnimalNamesQuery:
		return repository.find_all_distinct_animal_names()

	return null
