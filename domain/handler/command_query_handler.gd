extends Node
class_name CommandQueryHandler

const group_name = &"command_query_handler"

func _enter_tree() -> void:
	add_to_group(group_name)

func handle(dispatchable: Variant) -> Variant:
	assert(false, "Not implemented")
	return null

func can_handle(dispatchable: Variant) -> bool:
	assert(false, "Not implemented")
	return false
