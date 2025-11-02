extends VBoxContainer

signal color_changed(color: Color)
signal pick_icon_button_pressed

var animal_settings: Dictionary
var animal_name: String

@onready var _pictogram_rect: TextureRect = %PictogramRect
@onready var _pick_icon_button: Button = %PickIconButton
@onready var _pick_color_button: Button = %PickColorButton
@onready var _color_picker: ColorPicker = %ColorPicker
@onready var _animal_name_label: Label = %AnimalNameLabel
@onready var _question_mark: Texture2D = load("uid://uqghp2svgsaf")

func _ready():
	_pick_icon_button.pressed.connect(func(): pick_icon_button_pressed.emit())
	_pick_color_button.pressed.connect(func(): _color_picker.visible = !_color_picker.visible)
	_color_picker.color_changed.connect(func(color: Color):
		color_changed.emit(color)
	)

	update()

func update():
	if animal_settings["icon_path"] != "":
		_pictogram_rect.texture = ImageUtils.load_inverted(animal_settings["icon_path"])
		_pictogram_rect.modulate = animal_settings["color"]
	else:
		_pictogram_rect.texture = _question_mark

	_animal_name_label.text = animal_name
	_color_picker.color = animal_settings["color"]
