extends Control

signal pictogram_selected(image: Image)

@export var gbif_client: GBIFClient
@export var phylopic_client: PhylopicClient

var animal_name: String:
	get: return _search_edit.text
	set(p_value): _search_edit.text = p_value

@onready var _search_edit: LineEdit = %SearchEdit
@onready var _search_button: Button = %SearchButton
@onready var _result_tree: Tree = %ResultTree

var _images: Array[Image] = []

func _ready() -> void:
	assert(_search_edit)
	assert(_search_button)
	assert(_result_tree)

	assert(gbif_client)
	assert(phylopic_client)

	_search_button.pressed.connect(_on_search_button_pressed)
	_result_tree.button_clicked.connect(_on_result_tree_button_clicked)

func _on_search_button_pressed() -> void:
	_search_button.text = "Searching..."
	_search_button.disabled = true
	_search_edit.editable = false
	_result_tree.visible = false

	var vernacular_name := _search_edit.text
	var result: GBIFSearchResult = await gbif_client.search_by_vernacular_name(vernacular_name)

	_result_tree.clear()
	var root = _result_tree.create_item()

	for item in result.items:
		var image := await phylopic_client.find_picture_for_gbif_item(item)
		_images.append(image)

		var texture := ImageTexture.create_from_image(image)
		
		var tree_item := root.create_child()
		tree_item.set_icon(0, texture)
		tree_item.set_icon_max_width(0, 48)
		tree_item.set_text(1, item.canonical_name)
		tree_item.add_button(2, load("res://icons/question_mark.png"))

	_search_button.text = "Search"
	_search_button.disabled = false
	_search_edit.editable = true
	_result_tree.visible = true

func _on_result_tree_button_clicked(item: TreeItem, _column: int, _id: int, _mouse_button_index: int):
	var image: Image = _images[item.get_index()]
	pictogram_selected.emit(image)
