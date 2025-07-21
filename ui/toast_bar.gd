extends PanelContainer

@onready var _timer: Timer = $Timer
@onready var _label: Label = %Label
@onready var _close_button: Button = %CloseButton

func _ready() -> void:
	_close_button.pressed.connect(_hide)
	_timer.timeout.connect(_hide)

	visible = false

func show_toast(p_text: String, p_time_sec: float) -> void:
	_timer.one_shot = true
	_timer.stop()
	_timer.start(p_time_sec)

	_label.text = p_text
	visible = true

func _hide():
	_timer.stop()
	visible = false
