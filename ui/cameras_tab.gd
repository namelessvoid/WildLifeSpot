extends Control

var camera_repository: FSCameraRepository

var _cameras: Array[FSCamera]
var _selected_camera: FSCamera

@onready var _camera_list := %CameraList as ItemList
@onready var _new_camera_button := %NewCameraButton as Button
@onready var _save_camera_button := %SaveCameraButton as Button
@onready var _delete_camera_button := %DeleteCameraButton as Button
@onready var _camera_details_container := %CameraDetailsContainer as Container

@onready var _name_edit := %NameEdit as LineEdit
@onready var _model_edit := %ModelEdit as LineEdit
@onready var _manufacturer_edit = %ManufacturerEdit as LineEdit


func _ready() -> void:
	assert(_camera_list)
	assert(_new_camera_button)
	assert(_save_camera_button)
	assert(_delete_camera_button)
	assert(_camera_details_container)

	_camera_list.item_selected.connect(_on_camera_selected)
	_new_camera_button.pressed.connect(_on_new_camera_clicked)
	_save_camera_button.pressed.connect(_on_save_camera_clicked)
	_delete_camera_button.pressed.connect(_on_delete_camera_clicked)

	_hide_camera_details()

	_initialize.call_deferred()
	
func _initialize() -> void:
	_cameras = camera_repository.find_all()
	_update_camera_list()

func _show_camera_details(p_camera: FSCamera) -> void:
	_selected_camera = p_camera

	_name_edit.text = p_camera.name
	_manufacturer_edit.text = p_camera.manufacturer
	_model_edit.text = p_camera.model

	for child in _camera_details_container.get_children():
		child.visible = true

func _hide_camera_details() -> void:
	_selected_camera = null
	for child in _camera_details_container.get_children():
		child.visible = false

func _update_camera_list():
	_camera_list.clear()
	for camera in _cameras:
		_camera_list.add_item(camera.name)

func _on_new_camera_clicked() -> void:
	var camera = FSCamera.new()
	print(camera._id)
	camera_repository.save(camera)
	_cameras.append(camera)
	_update_camera_list()

func _on_save_camera_clicked() -> void:
	_selected_camera.name = _name_edit.text
	_selected_camera.manufacturer = _manufacturer_edit.text
	_selected_camera.model = _model_edit.text

	camera_repository.save(_selected_camera)

	var index = _camera_list.get_selected_items()[0]
	_update_camera_list()
	_camera_list.select(index)

func _on_delete_camera_clicked() -> void:
	camera_repository.delete(_selected_camera)
	_cameras = _cameras.filter(func(c) -> bool:
		return c._id != _selected_camera._id
	)
	_update_camera_list()
	_camera_list.deselect_all()
	_hide_camera_details()

func _on_camera_selected(p_index: int) -> void:
	var camera = _cameras[p_index]
	_show_camera_details(camera)
