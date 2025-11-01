extends Control

signal pictogram_selected(image: Image)

@export var gbif_client: GBIFClient
@export var phylopic_client: PhylopicClient

var animal_name: String:
	get: return _search_edit.text
	set(p_value): _search_edit.text = p_value

@onready var _search_edit: LineEdit = %SearchEdit
@onready var _search_button: Button = %SearchButton
@onready var _result_container: Container = %ResultContainer

const AnimalPictogramSelectItem := preload("uid://ccoq3tj2phxr8")
const _animal_pictogram_selection_item_scene := preload("uid://deswauwup3dfq")

var _images: Array[Image] = []

func _ready() -> void:
	assert(_search_edit)
	assert(_search_button)
	assert(_result_container)

	assert(gbif_client)
	assert(phylopic_client)

	_search_button.pressed.connect(_search)
	_search_edit.text_submitted.connect(func(_new_text): _search())
	_result_container.visible = false

func _search() -> void:
	_search_button.text = "Searching..."
	_search_button.disabled = true
	_search_edit.editable = false
	_result_container.visible = false

	var vernacular_name := _search_edit.text
	var result: GBIFSearchResult = await gbif_client.search_by_vernacular_name(vernacular_name)

	for child in _result_container.get_children():
		_result_container.remove_child(child)
		child.queue_free()

	for item in result.items:
		var image := await phylopic_client.find_picture_for_gbif_item(item)
		_images.append(image)

		var select_item: AnimalPictogramSelectItem = _animal_pictogram_selection_item_scene.instantiate()
		_result_container.add_child(select_item)
		select_item.pictogram_texture = ImageTexture.create_from_image(image)
		select_item.animal_name = item.canonical_name
		select_item.pictogram_selected.connect(func():
			_on_pictogram_selected(image)
		)

	_search_button.text = "Search"
	_search_button.disabled = false
	_search_edit.editable = true
	_result_container.visible = true

func _on_pictogram_selected(image: Image):
	pictogram_selected.emit(image)
