@abstract
class_name ValidatableControl
extends Control

signal validity_changed(is_valid: bool)

var validator: Callable

var _is_valid: bool = true

func is_valid() -> bool:
	return _is_valid

func validate() -> void:
	var _new_is_valid := validator.call(_get_value()) as bool
	if _new_is_valid != _is_valid:
		_is_valid = _new_is_valid
		validity_changed.emit(_new_is_valid)

@abstract
func _get_value() -> Variant
