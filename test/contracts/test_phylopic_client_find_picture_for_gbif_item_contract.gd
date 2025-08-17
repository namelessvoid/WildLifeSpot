extends GutTest

var _http_requester: HTTPRequester
var _phylopic_client: PhylopicClient

func before_each():
	_http_requester = add_child_autoqfree(HTTPRequester.new())
	_phylopic_client = PhylopicClient.new()
	_phylopic_client.http_requester = _http_requester
	add_child_autoqfree(_phylopic_client)

func test_returns_expected_texture():
	# Arrange
	var gbif_item := GBIFSearchResult.Item.new()
	gbif_item.kingdom_key = 1
	gbif_item.phylum_key= 44
	gbif_item.class_key = 212
	gbif_item.order_key = 729
	gbif_item.family_key = 5290
	gbif_item.genus_key = 2490714
	gbif_item.species_key = 2490719

	# Act
	var actual_image: Image = await _phylopic_client.find_picture_for_gbif_item(gbif_item)

	# Assert
	var expected_image: Image = load("res://test/fixtures/common_blackbird_phylopic.png")
	assert_eq_deep(actual_image.data, expected_image.data)
