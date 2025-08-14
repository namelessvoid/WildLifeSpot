extends Node
class_name PhylopicClient

@export var http_requester: HTTPRequester

const _default_headers := ["Accept: application/vnd.phylopic.v2+json"]
const _host := "https://api.phylopic.org"

func _ready() -> void:
	assert(http_requester)

func find_picture_from_gbif_item(p_gbif_item: GBIFSearchResult.Item) -> Texture2D:
	var build := await _get_build()
	var node_url := await _get_species_node_for_gbif_item(p_gbif_item, build)
	var primary_image_node_url := await _get_primary_image_node_url(node_url)
	var primary_image_url := await _get_image_url(primary_image_node_url)
	return await _get_image(primary_image_url)

func _get_build() -> String:
	var http_response := await http_requester.do_get_with_redirect(_host, "/", _default_headers)
	return str(http_response.json_body_to_dict()['build'] as int)

func _get_species_node_for_gbif_item(p_gbif_item: GBIFSearchResult.Item, p_build: String) -> String:
	var species_url = (
		"/resolve/gbif.org/species?build={build}"
	 	+ "&objectIDs={speciesKey},{genusKey},{familyKey},{orderKey},{classKey},{phylumKey},{kingdomKey}"
	).format({
		"build": p_build,
		"speciesKey": p_gbif_item.species_key,
		"genusKey": p_gbif_item.genus_key,
		"familyKey": p_gbif_item.family_key,
		"orderKey": p_gbif_item.order_key,
		"classKey": p_gbif_item.class_key,
		"phylumKey": p_gbif_item.phylum_key,
		"kingdomKey": p_gbif_item.kingdom_key
	})
	var http_response := await http_requester.do_get(_host + species_url, _default_headers)
	var body = http_response.json_body_to_dict()
	return body["href"]

func _get_primary_image_node_url(p_node_url: String) -> String:
	var http_response := await http_requester.do_get(_host + p_node_url, _default_headers)
	var body := http_response.json_body_to_dict()
	return body['_links']['primaryImage']['href']

func _get_image_url(p_image_node_url: String) -> String:
	var http_response := await http_requester.do_get(_host + p_image_node_url, _default_headers)
	var body := http_response.json_body_to_dict()
	return body['_links']['rasterFiles'][0]['href']

func _get_image(p_image_url: String) -> Texture2D:
	var http_response = await http_requester.do_get(p_image_url)
	var image = Image.new()
	image.load_png_from_buffer(http_response.body)
	return ImageTexture.create_from_image(image)
