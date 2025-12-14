extends Control
class_name SpotChart

var _easy_chart_scene: PackedScene = preload("res://addons/easy_charts/control_charts/chart.tscn")
var _easy_chart: Chart

func set_report(report: AnimalSpotReport):
	if _easy_chart:
		remove_child(_easy_chart)
		_easy_chart.queue_free()

	if report.MaxCount == 0:
		return

	var y_domain_max = report.MaxCount + 1 # Add one tick on top to get some nice spacing	
	var plot_functions := _get_functions_from_report(report)
	var chart_properties := _get_chart_properties(y_domain_max)

	_easy_chart = _easy_chart_scene.instantiate();
	_easy_chart.set_y_domain(0, y_domain_max)
	add_child(_easy_chart)
	_easy_chart.plot(plot_functions, chart_properties)

func _get_chart_properties(y_domain_max: int) -> ChartProperties:
	var chart_properties := ChartProperties.new()
	chart_properties.title = "Animals spotted"
	chart_properties.x_label = "Time"
	chart_properties.y_label = "Count"
	chart_properties.y_scale = y_domain_max
	chart_properties.show_legend = true
	chart_properties.interactive = true
	return chart_properties

func _get_functions_from_report(report: AnimalSpotReport) -> Array[Function]:
	var plot_functions: Array[Function] = []
	for animal_name in report.CountsPerAnimal.keys():
		var spots_by_animal_name_per_hour = report.CountsPerAnimal[animal_name]
		plot_functions.append(
			_get_animal_plot_function(
				animal_name,
				report.XLabels,
				spots_by_animal_name_per_hour
			)
		)
	return plot_functions

func _get_animal_plot_function(animal_name: String, x_labels: Array[String], spots_per_hour: Array[int]) -> Function:
	var animal_setting := Settings.get_or_create_animal_setting(animal_name)
	var icon: Texture2D = null
	if animal_setting["icon_path"]:
		icon = ImageUtils.load_inverted(animal_setting["icon_path"])

	return Function.new(
		x_labels,
		spots_per_hour,
		animal_name,
		{
			color = animal_setting["color"],
			type = Function.Type.BAR,
			bar_size = 5,
			icon = icon
		}
	)
