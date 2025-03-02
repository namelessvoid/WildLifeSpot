extends HBoxContainer

@onready var _name_edit: LineEdit = $NameEdit
@onready var _count_edit: LineEdit = $CountEdit
@onready var _delete_button: Button = $DeleteButton

func _ready() -> void:
	assert(_name_edit)
	assert(_count_edit)
	assert(_delete_button)

	_delete_button.pressed.connect(_delete)

func _delete():
	queue_free()
