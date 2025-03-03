extends Control

@onready var _day_list: ItemList = %DayList
@onready var _spot_details_container: VBoxContainer = %SpotDetailsContainer

func _ready():
	_spot_details_container.visible = false
