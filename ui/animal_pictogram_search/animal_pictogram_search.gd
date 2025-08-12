extends Control

@export var phylopic_client: Node

@onready var _search_edit: LineEdit = %SearchEdit
@onready var _search_button: Button = %SearchButton
@onready var _result_tree: Tree = %ResultTree
@onready var _gbif_client: GBIFClient = $GBIFClient

func _ready() -> void:
	assert(_search_edit)
	assert(_search_button)
	assert(_result_tree)
	assert(_gbif_client)

	_search_button.pressed.connect(_on_search_button_pressed)

func _on_search_button_pressed() -> void:
	_search_button.text = "Searching..."
	_search_button.disabled = true
	_search_edit.editable = false
	_result_tree.visible = false

	var vernacular_name := _search_edit.text
	var result: GBIFSearchResult = await _gbif_client.search_by_vernacular_name(vernacular_name)

	_result_tree.clear()
	var root = _result_tree.create_item()

	for item in result.results:
		var tree_item := root.create_child()
		tree_item.set_text(0, item.canonical_name)

	_search_button.text = "Search"
	_search_button.disabled = false
	_search_edit.editable = true
	_result_tree.visible = true

func _on_image_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var image := Image.new()
	image.load_png_from_buffer(body)
	#_texture_rect.texture = ImageTexture.create_from_image(image)
