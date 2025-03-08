extends Control

signal request_spot_bulk_add

var spot_repository: FSSpotRepository

@onready var _bulk_add_button: Button = %BulkAddButton
@onready var _date_list: ItemList = %DateList
@onready var _spot_details_container: VBoxContainer = %SpotDetailsContainer
@onready var _chart: BirdSpotChart = %BirdSpotChart

func refresh_date_list() -> void:
	var dates = spot_repository.find_all_dates()
	_date_list.clear()
	for date in dates:
		_date_list.add_item(date)

func _ready():
	assert(_bulk_add_button)
	assert(_date_list)
	assert(_spot_details_container)

	_bulk_add_button.pressed.connect(request_spot_bulk_add.emit)
	_date_list.item_selected.connect(_on_date_selected)

	_spot_details_container.visible = true

	_initialize.call_deferred()

func _initialize():
	assert(spot_repository)
	refresh_date_list()

func _on_date_selected(index: int) -> void:
	var date := _date_list.get_item_text(index)
	var spots = spot_repository.find_all_by_date(date)
	_chart.set_spots(spots)
