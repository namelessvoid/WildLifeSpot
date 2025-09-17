@abstract
class_name CommandQueryHandler
extends Node

const group_name = &"command_query_handler"

func _enter_tree() -> void:
	add_to_group(group_name)

@abstract
func handle(dispatchable: Variant) -> Variant

@abstract
func can_handle(dispatchable: Variant) -> bool
