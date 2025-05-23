extends Control

var spot_repository: AnimalSpotRepository

@onready var _date_list: ItemList = %DateList
@onready var _spot_details_container: VBoxContainer = %SpotDetailsContainer
@onready var _chart: SpotChart = %SpotChart

func refresh_date_list() -> void:
	var dates = spot_repository.find_all_dates()
	_date_list.clear()
	for date in dates:
		_date_list.add_item(date)

func _ready():
	assert(_date_list)
	assert(_spot_details_container)

	_date_list.item_selected.connect(_on_date_selected)

	_spot_details_container.visible = true
	_chart.visible = false

	_initialize.call_deferred()

func _initialize():
	assert(spot_repository)
	refresh_date_list()
	spot_repository.db_changed.connect(_on_db_changed)

func _on_date_selected(index: int) -> void:
	var date := _date_list.get_item_text(index)
	var spots = spot_repository.find_all_by_date(date)
	_chart.set_spots(spots)
	_chart.visible = true

func _on_db_changed():
	refresh_date_list()
	_chart.visible = false
