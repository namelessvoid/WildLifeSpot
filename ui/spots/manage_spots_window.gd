extends Window

@onready var _spots_tree: Tree = %SpotsTree

func _ready():
	assert(_spots_tree)

	visible = false
	close_requested.connect(hide)

	about_to_popup.connect(_on_about_to_popup)

	_spots_tree.item_collapsed.connect(_on_spots_tree_item_collapsed)

func _on_about_to_popup():
	_initialize();

func _on_spots_tree_item_collapsed(p_row: TreeItem):
	if p_row.collapsed:
		_collapse_date_row(p_row)
	else:
		_expand_date_row(p_row)

func _initialize():
	_spots_tree.clear()
	_spots_tree.set_column_title(0, "Time")
	_spots_tree.set_column_title(1, "Source")
	_spots_tree.set_column_title(2, "Animal")
	_spots_tree.set_column_title(3, "Count")
	var tree_root := _spots_tree.create_item()

	var dates = CommandQueryDispatcher.dispatch(FindAllAnimalSpotDatesQuery.new())
	for date in dates:
		var date_item := tree_root.create_child()
		date_item.set_text(0, date)
		date_item.collapsed = true

		var child = date_item.create_child()
		child.set_text(0, "Dummy")

func _expand_date_row(p_date_row: TreeItem):
	for child in p_date_row.get_children():
		child.free()

	var query := FindAllAnimalSpotsByDateQuery.new(p_date_row.get_text(0))
	var spots: Array[AnimalSpot] = CommandQueryDispatcher.dispatch(query)

	for spot in spots:
		var child := p_date_row.create_child()
		var date_time := Time.get_datetime_dict_from_datetime_string(spot.SpottedAt, false)
		child.set_text(0, "%02d:%02d:%02d" %  [date_time['hour'], date_time['minute'], date_time['second']])
		child.set_text(1, spot.Source)
		child.set_text(2, spot.AnimalName)
		child.set_text(3, str(spot.AnimalCount))
		

func _collapse_date_row(p_date_row: TreeItem):
	for child in p_date_row.get_children():
		child.free()

	var child := p_date_row.create_child()
	child.set_text(0, "Dummy")
