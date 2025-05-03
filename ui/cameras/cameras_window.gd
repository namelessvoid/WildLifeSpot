extends Window

var _cameras: Array[FSCamera]
var _selected_camera_id: int

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

	about_to_popup.connect(_about_to_popup)

	close_requested.connect(hide)

func _about_to_popup():
	_selected_camera_id = -1
	_update_camera_list()

func _show_camera_details(p_camera: FSCamera) -> void:
	_selected_camera_id = p_camera._id

	_name_edit.text = p_camera.name
	_manufacturer_edit.text = p_camera.manufacturer
	_model_edit.text = p_camera.model

	for child in _camera_details_container.get_children():
		child.visible = true

func _hide_camera_details() -> void:
	_selected_camera_id = -1
	for child in _camera_details_container.get_children():
		child.visible = false

func _update_camera_list():
	_cameras = CommandQueryDispatcher.dispatch(FindAllCamerasQuery.new())

	_camera_list.clear()
	for camera in _cameras:
		_camera_list.add_item(camera.name)

	if _selected_camera_id != -1:
		for i in _cameras.size():
			if _cameras[i]._id == _selected_camera_id:
				_on_camera_selected(i)
	else:
		_camera_list.deselect_all()
		_hide_camera_details()

func _on_new_camera_clicked() -> void:
	var camera = CommandQueryDispatcher.dispatch(CreateCameraCommand.new()) as FSCamera
	_selected_camera_id = camera._id
	_update_camera_list()

func _on_save_camera_clicked() -> void:
	var command = UpdateCameraCommand.new(
		_selected_camera_id,
		_name_edit.text,
		_manufacturer_edit.text,
		_model_edit.text
	)
	var camera = CommandQueryDispatcher.dispatch(command)

	_update_camera_list()

func _on_delete_camera_clicked() -> void:
	var command = DeleteCameraCommand.new(_selected_camera_id)
	CommandQueryDispatcher.dispatch(command)

	_selected_camera_id = -1
	_update_camera_list()

func _on_camera_selected(p_index: int) -> void:
	var camera = _cameras[p_index]
	_camera_list.select(p_index)
	_show_camera_details(camera)
