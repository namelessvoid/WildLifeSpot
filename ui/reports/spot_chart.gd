extends Control
class_name SpotChart

var _easy_chart_scene: PackedScene = preload("res://addons/easy_charts/control_charts/chart.tscn")
var _easy_chart: Chart
var _x_values: Array = range(0, 24).map(
	func(i: int) -> String: return "%d - %dh" % [i, i+1]
)

func set_spots(spots: Array[AnimalSpot]) -> void: 
	if _easy_chart:
		remove_child(_easy_chart)
		_easy_chart.queue_free()

	if spots == null:
		return

	_easy_chart = _easy_chart_scene.instantiate();
	_easy_chart.set_y_domain(0, _get_y_max(spots))
	add_child(_easy_chart)
	_easy_chart.plot(_get_plot_functions(spots), _get_chart_properties(spots))

func _get_chart_properties(spots: Array[AnimalSpot]) -> ChartProperties:
	var chart_properties := ChartProperties.new()
	chart_properties.title = "Animals spotted"
	chart_properties.x_label = "Time"
	chart_properties.y_label = "Count"
	chart_properties.y_scale = _get_y_max(spots)
	chart_properties.show_legend = true
	chart_properties.interactive = true
	return chart_properties

func _get_y_max(spots: Array[AnimalSpot]) -> int:
	var max_value = 0
	for spot in spots:
		if spot.AnimalCount > max_value:
			max_value = spot.AnimalCount

	# Add one tick on top to get some nice spacing
	max_value += 1

	return max_value

func _get_plot_functions(spots: Array[AnimalSpot]) -> Array[Function]:
	var spots_by_animal_name_per_hour = {}
	for spot in spots:
		var date_time_dict := Time.get_datetime_dict_from_datetime_string(spot.SpottedAt, false)
		var hour := date_time_dict["hour"] as int

		if !spots_by_animal_name_per_hour.has(spot.AnimalName):
			var empty_time_slots = []
			empty_time_slots.resize(24)
			empty_time_slots.fill(0)
			spots_by_animal_name_per_hour[spot.AnimalName] = empty_time_slots

		if spot.AnimalCount > spots_by_animal_name_per_hour[spot.AnimalName][hour]:
			spots_by_animal_name_per_hour[spot.AnimalName][hour] = spot.AnimalCount

	var plot_functions: Array[Function] = []
	for animal_name in spots_by_animal_name_per_hour.keys():
		var animal_setting := Settings.get_or_create_animal_setting(animal_name)
		plot_functions.append(
			_get_spot_plot_function(animal_name, animal_setting, spots_by_animal_name_per_hour[animal_name])
		)
	return plot_functions

func _get_spot_plot_function(animal: String, animal_setting: Dictionary, spots_per_hour: Array) -> Function:
	var icon: Texture2D = null
	if animal_setting["icon_path"]:
		icon = ImageUtils.load_inverted(animal_setting["icon_path"])

	return Function.new(
		_x_values,
		spots_per_hour,
		animal,
		{
			color = animal_setting["color"],
			type = Function.Type.BAR,
			bar_size = 5,
			icon = icon
		}
	)
