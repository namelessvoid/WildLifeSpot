extends Node

var _handlers: Array = []

func _ready():
	var handler_nodes = get_tree().get_nodes_in_group(
		CommandQueryHandler.group_name
	)
	for handler_node in handler_nodes:
		_handlers.append(handler_node)

func dispatch(dispatchable: Variant) -> Variant:
	var matching_handlers = _handlers.filter(func(handler) -> bool:
		if handler.has_method("can_handle"):
			return handler.can_handle(dispatchable)
		return handler.CanHandle(dispatchable)
	)

	if matching_handlers.size() > 1:
		assert(false, "More than one handler found")
		return

	if matching_handlers.size() == 0:
		assert(false, "No handler found")
		return

	var matching_handler = matching_handlers[0]
	if matching_handler.has_method("handle"):
		return matching_handler.handle(dispatchable)
	return matching_handler.Handle(dispatchable)
