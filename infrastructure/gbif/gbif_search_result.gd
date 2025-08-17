extends RefCounted
class_name GBIFSearchResult

var offset: int = 0
var limit: int = 0
var end_of_records: bool = true
var count: int = 0
var items: Array[Item] = []

func is_error() -> bool:
	return false

class Item:
	var canonical_name: String

	var kingdom_key: int
	var phylum_key: int
	var class_key: int
	var order_key: int
	var family_key: int
	var genus_key: int
	var species_key: int
