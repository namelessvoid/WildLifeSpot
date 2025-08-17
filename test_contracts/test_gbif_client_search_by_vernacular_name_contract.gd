extends GutTest

var _http_requester: HTTPRequester
var _gbif_client: GBIFClient

func before_all():
	_http_requester = HTTPRequester.new()
	add_child(_http_requester)

	_gbif_client = GBIFClient.new()
	_gbif_client.http_requester = _http_requester
	add_child(_gbif_client)

func after_all():
	_gbif_client.free()
	_http_requester.free()

func test_pagination():
	# Act
	var result := await _gbif_client.search_by_vernacular_name("Blackbird")

	# Asert
	assert_eq(result.count, 38)
	assert_false(result.end_of_records)
	assert_eq(result.limit, 20)
	assert_eq(result.items.size(), 20)

func test_handles_spaces_in_vernacular_name():
	# Act
	var result := await _gbif_client.search_by_vernacular_name("Common blackbird")

	# Assert
	assert_eq(result.count, 1)

func test_deserializes_items():
	# Act
	var result := await _gbif_client.search_by_vernacular_name("common blackbird")

	# Assert
	var item := result.items[0]
	assert_eq(item.canonical_name, "Turdus merula")
	assert_eq(item.kingdom_key, 1)
	assert_eq(item.phylum_key, 44)
	assert_eq(item.class_key, 212)
	assert_eq(item.order_key, 729)
	assert_eq(item.family_key, 5290)
	assert_eq(item.genus_key, 2490714)
	assert_eq(item.species_key, 2490719)
