extends Window

const SpotControl := preload("uid://cmcpbtxk0apc6")

@onready var _spot_control: SpotControl = %SpotControl
@onready var _save_button: Button = %SaveButton
@onready var _close_button: Button = %CloseButton

func _ready() -> void:
	assert(_spot_control)
	assert(_close_button)

	about_to_popup.connect(_on_about_to_popup)
	_close_button.pressed.connect(hide)
	close_requested.connect(hide)
	_save_button.pressed.connect(_on_save_button_pressed)

func _on_about_to_popup() -> void:
	_spot_control.reset()

func _on_save_button_pressed() -> void:
	var spots := _spot_control.create_spots()
	for spot in spots:
		var command := CreateAnimalSpotCommand.new(spot)
		CommandQueryDispatcher.dispatch(command)
	GlobalSignals.animal_spots_dirtied.emit()
