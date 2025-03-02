class_name AnimalBox
extends HBoxContainer

@onready var _name_edit: LineEdit = $NameEdit
@onready var _count_spin_box: SpinBox = $CountSpinBox
@onready var _delete_button: Button = $DeleteButton

func get_animal_name() -> String:
	return _name_edit.text

func get_animal_count() -> int:
	return _count_spin_box.value

func _ready() -> void:
	assert(_name_edit)
	assert(_count_spin_box)
	assert(_delete_button)

	_delete_button.pressed.connect(_delete)

func _delete():
	queue_free()
