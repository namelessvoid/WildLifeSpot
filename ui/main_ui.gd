extends Control

@export var camera_repository: FSCameraRepository
@export var spot_repository: FSSpotRepository
@export var processed_image_repository: FSProcessedImageRepository
@export var exif_reader: ExifReader
@export var file_hasher: FileHasher

@onready var _file_menu := %File as PopupMenu
@onready var _spots_tab := %Spots
@onready var _cameras_tab := %Cameras
@onready var _bulk_spot_file_dialog := %BulkSpotFileDialog
@onready var _bulk_spot_window := %BulkSpotWindow

func _ready():
	assert(camera_repository)
	assert(spot_repository)
	assert(processed_image_repository)
	assert(exif_reader)
	assert(file_hasher)

	assert(_file_menu)
	assert(_cameras_tab)
	assert(_bulk_spot_file_dialog)

	_file_menu.id_pressed.connect(_on_file_menu_id_pressed)
	_spots_tab.request_spot_bulk_add.connect(_bulk_spot_file_dialog.popup_centered_ratio.bind(0.9))
	_bulk_spot_file_dialog.files_selected.connect(_on_bulk_spot_files_selected)
	_bulk_spot_window.finished.connect(_spots_tab.refresh_date_list)

	_cameras_tab.camera_repository = camera_repository
	_spots_tab.spot_repository = spot_repository
	_bulk_spot_window.camera_repository = camera_repository
	_bulk_spot_window.spot_repository = spot_repository
	_bulk_spot_window.processed_images_repository = processed_image_repository
	_bulk_spot_window.exif_reader = exif_reader
	_bulk_spot_window.file_hasher = file_hasher

func _on_file_menu_id_pressed(p_id: int):
	match p_id:
		2: get_tree().quit()

func _on_bulk_spot_files_selected(files: PackedStringArray) -> void:
	_bulk_spot_window.popup_centered_ratio(0.9)
	_bulk_spot_window.selected_files = files
