extends Control

@export var camera_repository: FSCameraRepository

@onready var _file_menu := %File as PopupMenu
@onready var _cameras_tab := %Cameras
@onready var _spot_bulk_file_dialog := %SpotBulkFileDialog
@onready var _bulk_spot_window := %BulkSpotWindow

func _ready():
	assert(_file_menu)
	assert(_cameras_tab)
	assert(_spot_bulk_file_dialog)

	_file_menu.id_pressed.connect(_on_file_menu_id_pressed)
	_spot_bulk_file_dialog.dir_selected.connect(_on_spot_bulk_directory_selected)

	_cameras_tab.camera_repository = camera_repository

func _on_file_menu_id_pressed(p_id: int):
	match p_id:
		0: get_tree().quit()
		1: _spot_bulk_file_dialog.popup_centered_ratio(0.9)

func _on_spot_bulk_directory_selected(dir: String) -> void:
	_bulk_spot_window.directory = dir
	_bulk_spot_window.popup_centered_ratio(0.9)
