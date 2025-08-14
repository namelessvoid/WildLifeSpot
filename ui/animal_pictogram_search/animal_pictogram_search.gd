extends Control

@export var gbif_client: GBIFClient
@export var phylopic_client: PhylopicClient

@onready var _search_edit: LineEdit = %SearchEdit
@onready var _search_button: Button = %SearchButton
@onready var _result_tree: Tree = %ResultTree

func _ready() -> void:
	assert(_search_edit)
	assert(_search_button)
	assert(_result_tree)

	assert(gbif_client)
	assert(phylopic_client)

	_search_button.pressed.connect(_on_search_button_pressed)

func _on_search_button_pressed() -> void:
	_search_button.text = "Searching..."
	_search_button.disabled = true
	_search_edit.editable = false
	_result_tree.visible = false

	var vernacular_name := _search_edit.text
	var result: GBIFSearchResult = await gbif_client.search_by_vernacular_name(vernacular_name)

	_result_tree.clear()
	var root = _result_tree.create_item()

	for item in result.results:
		var tree_item := root.create_child()
		tree_item.set_text(1, item.canonical_name)

		var texture := await phylopic_client.find_picture_from_gbif_item(item)
		tree_item.set_icon(0, texture)
		tree_item.set_icon_max_width(0, 48)

	_search_button.text = "Search"
	_search_button.disabled = false
	_search_edit.editable = true
	_result_tree.visible = true
