extends Window

var directory: String:
	get: return directory
	set(value):
		directory = value
		_on_directory_changed()

@onready var _image_rect: TextureRect = %ImageRect
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _date_time_edit: LineEdit = %DateTimeEdit
@onready var _temperature_edit: LineEdit = %TemperatureEdit
@onready var _camera_options_button: OptionButton = %CameraOptionsButton
@onready var _animal_container: VBoxContainer = %AnimalContainer
@onready var _add_new_animal_button: Button = %AddNewAnimalButton
@onready var _skip_button: Button = %SkipButton
@onready var _save_and_next_button: Button = %SaveAndNextButton

var _paths: PackedStringArray
var _next_image: int

func _ready() -> void:
	_skip_button.pressed.connect(_show_next_image)
	_save_and_next_button.pressed.connect(_save_and_show_next_image)

func _on_directory_changed() -> void:
	var file_names := Array(DirAccess.get_files_at(directory))\
		.filter(func(file_name: String) -> bool:
			var lowercase_name = file_name.to_lower()
			return lowercase_name.ends_with('.jpg') || lowercase_name.ends_with('.png')
	).map(func(file_name: String) -> String:
		return directory + "/" + file_name
	)
	_paths = PackedStringArray(file_names)
	_next_image = 0
	_show_next_image()

func _save_and_show_next_image() -> void:
	# save
	_show_next_image()

func _show_next_image():
	if _next_image == _paths.size():
		hide()
		return

	var file_path := _paths[_next_image]
	var image := Image.load_from_file(file_path)
	_image_rect.texture = ImageTexture.create_from_image(image)
	
	_next_image += 1
