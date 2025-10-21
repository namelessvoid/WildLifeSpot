extends HBoxContainer

signal color_changed(color: Color)
signal pick_icon_button_pressed

var animal_settings: Dictionary
var animal_name: String

@onready var _pick_icon_button: Button = $PickIconButton
@onready var _pick_color_button: ColorPickerButton = $PickColorButton
@onready var _animal_name_label: Label = $AnimalNameLabel
@onready var _question_mark: Texture2D = load("uid://uqghp2svgsaf")

func _ready():
	if animal_settings["icon_path"] != "":
		_pick_icon_button.icon = ImageUtils.load_inverted(animal_settings["icon_path"])
		_pick_icon_button.modulate = animal_settings["color"]
	else:
		_pick_icon_button.icon = _question_mark

	_pick_color_button.color = animal_settings["color"]
	_animal_name_label.text = animal_name

	_pick_icon_button.pressed.connect(func(): pick_icon_button_pressed.emit())
	_pick_color_button.color_changed.connect(func(color: Color): color_changed.emit(color))
