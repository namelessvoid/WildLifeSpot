class_name AnimalBox
extends HBoxContainer

@onready var _name_edit: LineEdit = $NameEdit
@onready var _count_spin_box: SpinBox = $CountSpinBox
@onready var _delete_button: Button = $DeleteButton

func set_animal_name(p_name: String) -> void:
	_name_edit.text = p_name

func get_animal_name() -> String:
	return _name_edit.text

func set_animal_count(p_count: int) -> void:
	_count_spin_box.value = p_count

func get_animal_count() -> int:
	return _count_spin_box.value as int

func _ready() -> void:
	assert(_name_edit)
	assert(_count_spin_box)
	assert(_delete_button)

	# Do not focus line edit when spin buttons pressed
	_count_spin_box.value_changed.connect(func(_value):
		_count_spin_box.get_line_edit().release_focus()
	)

	_delete_button.pressed.connect(queue_free)
