extends CommandQueryHandler

@export var repository: AnimalSpotRepository

func can_handle(dispatchable: Variant) -> bool:
	return dispatchable is DeleteExistingAnimalSpots \
		|| dispatchable is FindAllAnimalSpotDatesQuery \
		|| dispatchable is FindAllAnimalSpotsByDateQuery

func handle(dispatchable: Variant) -> Variant:
	if dispatchable is DeleteExistingAnimalSpots:
		repository.delete_by_source_and_spotted_at(dispatchable._source, dispatchable._spotted_at)
	elif dispatchable is FindAllAnimalSpotDatesQuery:
		return repository.find_all_dates()
	elif dispatchable is FindAllAnimalSpotsByDateQuery:
		return repository.find_all_by_date(dispatchable._date)

	return null
