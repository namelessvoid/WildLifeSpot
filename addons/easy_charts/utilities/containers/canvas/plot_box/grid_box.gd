extends Control
class_name GridBox

var x_tick_count: int = 0
var x_domain: ChartAxisDomain = null
var x_labels_function: Callable = Callable()
var x_label_centered: bool = false

var y_tick_count: int = 0
var y_domain: ChartAxisDomain = null
var y_labels_function: Callable = Callable()

var box: Rect2
var plot_box: Rect2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_domains(x_domain: ChartAxisDomain, y_domain: ChartAxisDomain) -> void:
	self.x_domain = x_domain
	self.y_domain = y_domain

func set_labels_functions(x_labels_function: Callable, y_labels_function: Callable) -> void:
	self.x_labels_function = x_labels_function
	self.y_labels_function = y_labels_function

func _draw() -> void:
	if get_parent().chart_properties == null:
		printerr("Cannot draw GridBox without ChartProperties!")
		return
	
	self.box = get_parent().get_box()
	self.plot_box = get_parent().get_plot_box()
	
	if get_parent().chart_properties.draw_background:
		_draw_background()
	
	if get_parent().chart_properties.draw_grid_box:
		_draw_x_ticks()
		_draw_y_ticks()
	
	if get_parent().chart_properties.draw_origin:
		_draw_origin()
	
	if get_parent().chart_properties.draw_bounding_box:
		_draw_bounding_box()

func _draw_background() -> void:
	draw_rect(self.box, get_parent().chart_properties.colors.background, true)# false) TODOGODOT4 Antialiasing argument is missing

func _draw_bounding_box() -> void:
	var box: Rect2 = self.box
	box.position.y += 1
	draw_rect(box, get_parent().chart_properties.colors.bounding_box, false, 1)# true) TODOGODOT4 Antialiasing argument is missing

func _draw_origin() -> void:
	var xorigin: float = ECUtilities._map_domain(0.0, x_domain, ChartAxisDomain.from_bounds(self.plot_box.position.x, self.plot_box.end.x))
	var yorigin: float = ECUtilities._map_domain(0.0, y_domain, ChartAxisDomain.from_bounds(self.plot_box.end.y, self.plot_box.position.y))
	
	draw_line(Vector2(xorigin, self.plot_box.position.y), Vector2(xorigin, self.plot_box.position.y + self.plot_box.size.y), get_parent().chart_properties.colors.origin, 1)
	draw_line(Vector2(self.plot_box.position.x, yorigin), Vector2(self.plot_box.position.x + self.plot_box.size.x, yorigin), get_parent().chart_properties.colors.origin, 1)
	draw_string(
		get_parent().chart_properties.font, Vector2(xorigin, yorigin) - Vector2(15, -15), "O", HORIZONTAL_ALIGNMENT_CENTER, -1, 
		ThemeDB.fallback_font_size, get_parent().chart_properties.colors.text, TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL
		)


func _draw_x_ticks() -> void:
	# draw x tick lines
	
	# 1. the amount of lines is equals to the X_scale: it identifies in how many sectors the x domain
	#    should be devided
	# 2. calculate the spacing between each line in pixel. It is equals to x_sampled_domain / x_scale
	# 3. calculate the offset in the real x domain, which is x_domain / x_scale.
	var scaler: int = x_tick_count
	
	var x_pixel_dist: float = self.plot_box.size.x / (scaler) \
		if x_label_centered \
		else self.plot_box.size.x / (scaler - 1)
	
	var vertical_grid: PackedVector2Array = []
	var vertical_ticks: PackedVector2Array = []
	
	for _x in (scaler):
		var x_position: float = (_x * x_pixel_dist) + self.plot_box.position.x

		var x_val: Variant
		if x_domain.is_discrete:
			x_val = _x
		else:
			x_val = ECUtilities._map_domain(x_position, ChartAxisDomain.from_bounds(self.plot_box.position.x, self.plot_box.end.x), x_domain)

		var top: Vector2 = Vector2(x_position, self.box.position.y)
		var bottom: Vector2 = Vector2(x_position, self.box.end.y)
		
		vertical_grid.append(top)
		vertical_grid.append(bottom)
		
		vertical_ticks.append(bottom)
		vertical_ticks.append(bottom + Vector2(0, get_parent().chart_properties.x_tick_size))
		
		# Draw V Tick Labels
		if get_parent().chart_properties.show_tick_labels:
			var tick_lbl: String = x_domain.get_tick_label(x_val, self.x_labels_function)
			draw_string(
				get_parent().chart_properties.font, 
				_get_vertical_tick_label_pos(bottom, tick_lbl, x_pixel_dist),
				tick_lbl,
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				ThemeDB.fallback_font_size,
				get_parent().chart_properties.colors.text,
				TextServer.JUSTIFICATION_NONE,
				TextServer.DIRECTION_AUTO,
				TextServer.ORIENTATION_HORIZONTAL
			)
	
	# Draw V Grid
	if get_parent().chart_properties.draw_vertical_grid:
		draw_multiline(vertical_grid, get_parent().chart_properties.colors.grid, 1)
	
	# Draw V Ticks
	if get_parent().chart_properties.draw_ticks:
		draw_multiline(vertical_ticks, get_parent().chart_properties.colors.ticks, 1)


func _draw_y_ticks() -> void:
	# 1. the amount of lines is equals to the y_scale: it identifies in how many sectors the y domain
	#    should be devided
	# 2. calculate the spacing between each line in pixel. It is equals to y_sampled_domain / y_scale
	# 3. calculate the offset in the real y domain, which is y_domain / y_scale.
	var scaler: int = y_tick_count
	var y_pixel_dist: float = self.plot_box.size.y / scaler

	var horizontal_grid: PackedVector2Array = []
	var horizontal_ticks: PackedVector2Array = []
	
	for _y in (scaler):
		var y_sampled_val: float = (_y * y_pixel_dist) + self.plot_box.position.y

		var y_val: float
		if y_domain.is_discrete:
			y_val = _y
		else:
			y_val = ECUtilities._map_domain(y_sampled_val, ChartAxisDomain.from_bounds(self.plot_box.end.y, self.plot_box.position.y), y_domain)

		var left: Vector2 = Vector2(self.box.position.x, y_sampled_val)
		var right: Vector2 = Vector2(self.box.end.x, y_sampled_val)
		
		horizontal_grid.append(left)
		horizontal_grid.append(right)
		
		horizontal_ticks.append(left)
		horizontal_ticks.append(left - Vector2(get_parent().chart_properties.y_tick_size, 0))
		
		# Draw H Tick Labels
		if get_parent().chart_properties.show_tick_labels:
			var tick_lbl: String = y_domain.get_tick_label(y_val, y_labels_function)
			draw_string(
				get_parent().chart_properties.font, 
				_get_horizontal_tick_label_pos(left, tick_lbl),
				tick_lbl,
				HORIZONTAL_ALIGNMENT_CENTER,
				-1, ThemeDB.fallback_font_size,
				get_parent().chart_properties.colors.text,
				TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL
			)
	
	# Draw H Grid
	if get_parent().chart_properties.draw_horizontal_grid:
		draw_multiline(horizontal_grid, get_parent().chart_properties.colors.grid, 1)
	
	# Draw H Ticks
	if get_parent().chart_properties.draw_ticks:
		draw_multiline(horizontal_ticks, get_parent().chart_properties.colors.ticks, 1)
		

func _get_vertical_tick_label_pos(base_position: Vector2, text: String, x_pixel_dist: float) -> Vector2:
	var x_offset: float = 0 if !x_label_centered else 0.5 * x_pixel_dist

	return  base_position + Vector2(
		- get_parent().chart_properties.font.get_string_size(text).x / 2 + x_offset,
		ThemeDB.fallback_font_size + get_parent().chart_properties.x_tick_size
	)

func _get_horizontal_tick_label_pos(base_position: Vector2, text: String) -> Vector2:
	return base_position - Vector2(
		get_parent().chart_properties.font.get_string_size(text).x + get_parent().chart_properties.y_tick_size + get_parent().chart_properties.x_ticklabel_space, 
		- ThemeDB.fallback_font_size * 0.35
	)

func _get_tick_label(line_index: int, line_value: float, axis_has_decimals: bool, labels_function: Callable) -> String:
	var tick_lbl: String = ""
	if labels_function.is_null():
		tick_lbl = ECUtilities._format_value(line_value, axis_has_decimals)
	else:
		tick_lbl = labels_function.call(line_value)
	return tick_lbl
