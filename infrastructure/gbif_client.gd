extends Node
class_name GBIFClient

const GBIFSearchResult = preload("res://phylopic/gbif_search_result.gd")

@export var http_requester: HTTPRequester

const _host_name := "https://api.gbif.org"
const _search_url_template = "/v1/species/search?q={vernacular_name}&qField=VERNACULAR&rank=species&status=ACCEPTED&datasetKey=d7dddbf4-2cf0-4f39-9b2a-bb099caae36c"

func _ready() -> void:
	assert(http_requester)

func search_by_vernacular_name(p_vernacular_name: String) -> GBIFSearchResult:
	var url := _search_url_template.format({"vernacular_name": p_vernacular_name})
	var http_result = await http_requester.do_get(_host_name, url)

	if http_result.status_code != 200:
		return GBIFSearchErrorResult.new()

	var result_dict := http_result.json_body_to_dict()
	var result := GBIFSearchResult.new()
	result.count = result_dict["count"]
	result.end_of_records = result_dict["endOfRecords"]
	result.limit = result_dict["limit"]
	result.offset = result_dict["offset"]
	
	for item_dict in result_dict["results"]:
		var item = GBIFSearchResult.Item.new()
		item.canonical_name = item_dict["canonicalName"]
		item.kingdom_key  = item_dict["kingdomKey"]
		item.phylum_key = item_dict["phylumKey"]
		item.class_key = item_dict["classKey"]
		item.order_key = item_dict["orderKey"]
		item.family_key = item_dict["familyKey"]
		item.genus_key = item_dict["genusKey"]
		item.species_key = item_dict["speciesKey"]
		result.results.append(item)

	return result
