extends GutTest

var _validatable_line_edit := preload("uid://c0ek5dq78s652")

func test_should_init_valid():
	# Act
	var validatable_line_edit: ValidatableLineEdit = _validatable_line_edit.instantiate()
	add_child_autofree(validatable_line_edit)

	# Assert
	assert_true(validatable_line_edit.is_valid())
	assert_eq(validatable_line_edit._validation_message_label.text, "")

func test_should_validate_and_update_validation_label():
	# Arrange
	var validatable_line_edit: ValidatableLineEdit = _validatable_line_edit.instantiate()
	add_child_autofree(validatable_line_edit)
	validatable_line_edit.validator = func(p_value: String):
		return p_value == "valid input"

	# Act (invalid)
	validatable_line_edit.text = "invalid input"
	validatable_line_edit._line_edit.editing_toggled.emit(false)

	# Assert
	assert_false(validatable_line_edit.is_valid())
	assert_eq(validatable_line_edit._validation_message_label.text, "Invalid input")

	# Act (valid)
	validatable_line_edit.text = "valid input"
	validatable_line_edit._on_line_edit_editing_toggled(false)

	# Assert
	assert_true(validatable_line_edit.is_valid())
	assert_eq(validatable_line_edit._validation_message_label.text, "")
