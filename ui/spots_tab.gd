extends Control

var spot_repository: FSSpotRepository

@onready var _day_list: ItemList = %DayList
@onready var _spot_details_container: VBoxContainer = %SpotDetailsContainer

func _ready():
	_spot_details_container.visible = true
	_initialize.call_deferred()

func _initialize():
	assert(spot_repository)
	var days = spot_repository.find_all_days()
	_day_list.clear()
	for day in days:
		_day_list.add_item(day)
