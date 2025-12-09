extends RefCounted

var _animal_box: AnimalBox

func _init(p_animal_box: AnimalBox) -> void:
	_animal_box = p_animal_box

func press_remove_button() -> void:
	_animal_box._delete_button.pressed.emit()

func enter_animal_name(p_animal_name: String) -> void:
	_animal_box._name_edit.text = p_animal_name

func enter_animal_count(p_animal_count: int) -> void:
	_animal_box._count_spin_box.value = p_animal_count
