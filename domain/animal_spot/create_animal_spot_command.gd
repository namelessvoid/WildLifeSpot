extends RefCounted
class_name CreateAnimalSpotCommand

var _spot: AnimalSpot

func _init(p_spot: AnimalSpot) -> void:
	_spot = p_spot
