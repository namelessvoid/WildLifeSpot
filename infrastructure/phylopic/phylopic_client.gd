extends Node
class_name PhylopicClient

@export var http_requester: HTTPRequester

const _default_headers := ["Accept: application/vnd.phylopic.v2+json"]
const _host := "https://api.phylopic.org"
var _build: String = ""

func _ready() -> void:
	assert(http_requester)

func find_picture_for_gbif_item(p_gbif_item: GBIFSearchResult.Item) -> Image:
	await _ensure_build()
	var node_url := await _get_species_node_for_gbif_item(p_gbif_item)
	var primary_image_url := await _get_primary_image_url(node_url)
	return await _get_image(primary_image_url)

func _ensure_build() -> void:
	if !_build.is_empty():
		return

	var http_response := await http_requester.do_get_with_redirect(_host, "/", _default_headers)
	_build = str(http_response.json_body_to_dict()['build'] as int)

func _get_species_node_for_gbif_item(p_gbif_item: GBIFSearchResult.Item) -> String:
	var species_url = (
		"/resolve/gbif.org/species?build={build}"
	 	+ "&objectIDs={speciesKey},{genusKey},{familyKey},{orderKey},{classKey},{phylumKey},{kingdomKey}"
	).format({
		"build": _build,
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

func _get_primary_image_url(p_node_url: String) -> String:
	var url := _host + p_node_url + "&embed_primaryImage=true"
	var http_response := await http_requester.do_get(url, _default_headers)
	var body := http_response.json_body_to_dict()
	return body['_embedded']['primaryImage']['_links']['rasterFiles'][-1]['href']

func _get_image(p_image_url: String) -> Image:
	var http_response = await http_requester.do_get(p_image_url)
	var image = Image.new()
	image.load_png_from_buffer(http_response.body)
	return image
