extends VBoxContainer

signal pictogram_selected

@onready var _animal_icon_texture_rect: TextureRect = $AnimalIconTextureRect
@onready var _animal_name_label: Label = $AnimalNameLabel
@onready var _choose_icon_button: Button = $ChooseIconButton

var pictogram_texture: Texture2D:
	get: return _animal_icon_texture_rect.texture
	set(value): _animal_icon_texture_rect.texture = value

var animal_name: String:
	get: return _animal_name_label.text
	set(value): _animal_name_label.text = value

func _ready():
	_choose_icon_button.pressed.connect(pictogram_selected.emit)
