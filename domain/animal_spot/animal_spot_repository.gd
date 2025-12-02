@abstract
class_name AnimalSpotRepository
extends Node

@abstract
func save(p_spot: AnimalSpot) -> void

@abstract
func find_all() -> Array[AnimalSpot]

@abstract
func find_all_by(p_source: String, p_camera_id: int, p_spotted_at: String) -> Array[AnimalSpot]

@abstract
func find_all_by_date(date: String) -> Array[AnimalSpot]

@abstract
func find_all_dates() -> PackedStringArray

@abstract
func find_all_distinct_animal_names() -> PackedStringArray

@abstract
func delete_by_source_and_spotted_at(source: String, spotted_at: String) -> void
