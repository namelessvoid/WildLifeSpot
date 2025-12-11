@tool
class_name ValidatableLineEdit
extends ValidatableControl

signal text_changed(p_text: String)

@export
var placeholder_text: String:
	get: return _line_edit.placeholder_text
	set(p_value): _line_edit.placeholder_text = p_value

var text: String:
	get: return _line_edit.text
	set(p_value): _line_edit.text = p_value

@onready var _line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var _validation_message_label: Label = $VBoxContainer/ValidationMessageLabel

func _ready() -> void:
	_validation_message_label.text = ""
	custom_minimum_size.y = $VBoxContainer.size.y

	_line_edit.editing_toggled.connect(_on_line_edit_editing_toggled)
	validity_changed.connect(_on_validity_changed)

func _get_value() -> Variant:
	return _line_edit.text

func _on_validity_changed(p_is_valid: bool) -> void:
	if p_is_valid:
		_validation_message_label.text = ""
	else:
		_validation_message_label.text = "Invalid input"

func _on_line_edit_editing_toggled(p_is_editing) -> void:
	if p_is_editing:
		return
	validate()
	text_changed.emit(text)
