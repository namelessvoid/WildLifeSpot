extends RefCounted

var _animal_box: AnimalBox

func _init(p_animal_box: AnimalBox) -> void:
	_animal_box = p_animal_box

func press_remove_button() -> void:
	_animal_box._delete_button.pressed.emit()
