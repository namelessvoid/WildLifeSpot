extends Control

@onready var _date_list: ItemList = %DateList
@onready var _spot_details_container: VBoxContainer = %SpotDetailsContainer
@onready var _chart: SpotChart = %SpotChart

var _selected_date: String = ""

func _ready():
	assert(_date_list)
	assert(_spot_details_container)

	GlobalSignals.animal_spots_dirtied.connect(_on_animal_spots_dirtied)
	GlobalSignals.database_changed.connect(_on_db_changed)

	_date_list.item_selected.connect(_on_date_selected)

	_spot_details_container.visible = true
	_chart.visible = false

	_initialize.call_deferred()

func _initialize():
	_refresh_date_list()

func _on_date_selected(index: int) -> void:
	_selected_date = _date_list.get_item_text(index)
	_update_chart()

func _on_animal_spots_dirtied() -> void:
	_refresh_date_list()
	_update_chart()

func _on_db_changed():
	_refresh_date_list()
	_chart.visible = false

func _refresh_date_list() -> void:
	# New logic
	var query = FindReportDateOptionsQuery.new()
	query.ReportOptions.Granularity = ReportOptions.GranularityHourly()
	var result = CommandQueryDispatcher.dispatch(query) as Array[String]

	_date_list.clear()
	for item in result:
		_date_list.add_item(item)

func _update_chart() -> void:
	if _selected_date.is_empty():
		return

	var query := FindAllAnimalSpotsByDateQuery.new(_selected_date)
	var spots := CommandQueryDispatcher.dispatch(query) as Array[AnimalSpot]
	_chart.set_spots(spots)
	_chart.visible = true
