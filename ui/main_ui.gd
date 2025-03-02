extends Control

@export var camera_repository: FSCameraRepository

@onready var _cameras_tab := %Cameras

func _ready():
	assert(_cameras_tab)

	_cameras_tab.camera_repository = camera_repository
