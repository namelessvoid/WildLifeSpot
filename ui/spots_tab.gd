extends Control

signal request_spot_bulk_add

var spot_repository: FSSpotRepository

@export var chart_scene: PackedScene
@export var colors: Array[Color]

@onready var _bulk_add_button: Button = %BulkAddButton
@onready var _date_list: ItemList = %DateList
@onready var _spot_details_container: VBoxContainer = %SpotDetailsContainer
@onready var _chart: Chart

var _chart_properties: ChartProperties

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

	_chart_properties = ChartProperties.new()
	_chart_properties.colors.frame = Color("#161a1d")
	_chart_properties.colors.background = Color.TRANSPARENT
	_chart_properties.colors.grid = Color("#283442")
	_chart_properties.colors.ticks = Color("#283442")
	_chart_properties.colors.text = Color.WHITE_SMOKE
	_chart_properties.draw_bounding_box = false
	_chart_properties.title = "Animals spotted"
	_chart_properties.x_label = "Time"
	_chart_properties.y_label = "Count"
	_chart_properties.max_samples = 24
	_chart_properties.x_scale = 23
	#_chart_properties.y_scale = 1
	_chart_properties.show_legend = true
	_chart_properties.interactive = true

func _initialize():
	assert(spot_repository)
	refresh_date_list()

func _on_date_selected(index: int) -> void:
	var date := _date_list.get_item_text(index)
	var spots = spot_repository.find_all_by_date(date)

	var spots_by_bird_per_hour = {}
	for spot in spots:
		var date_time_dict := Time.get_datetime_dict_from_datetime_string(spot.date_time, false)
		var hour := date_time_dict["hour"] as int

		for animal in spot.get_animals():
			if !spots_by_bird_per_hour.has(animal):
				var empty_time_slots = []
				empty_time_slots.resize(24)
				empty_time_slots.fill(0)
				spots_by_bird_per_hour[animal] = empty_time_slots

			if spot.get_animal_count(animal) > spots_by_bird_per_hour[animal][hour]:
				spots_by_bird_per_hour[animal][hour] = spot.get_animal_count(animal)

	print(spots_by_bird_per_hour)

	var hours: Array[int] = []
	hours.resize(24)
	for i in range(0, 24):
		hours[i] = i

	var sample_colors := colors.duplicate()
	var plot_functions: Array[Function] = []
	for animal in spots_by_bird_per_hour.keys():
		var color = sample_colors.pop_front()
		plot_functions.append(
			_bird_plot_function(animal, hours, spots_by_bird_per_hour[animal], color)
		)
	_redraw_chart(plot_functions)

func _bird_plot_function(animal: String, hours: Array[int], spots_per_hour: Array, color: Color) -> Function:
	return Function.new(
		hours,
		spots_per_hour,
		animal,
		{
			color = color,
			marker = Function.Marker.CROSS,
			type = Function.Type.SCATTER
		}
	)

func _redraw_chart(p_functions: Array[Function]):
	if _chart:
		_spot_details_container.remove_child(_chart)
		_chart.queue_free()

	_chart = chart_scene.instantiate()
	_spot_details_container.add_child(_chart)
	_chart.plot(p_functions, _chart_properties)
