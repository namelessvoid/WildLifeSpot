extends Node

var _handlers: Array[CommandQueryHandler] = []

func _ready():
	var handler_nodes = get_tree().get_nodes_in_group(
		CommandQueryHandler.group_name
	)
	for handler_node in handler_nodes:
		_handlers.append(handler_node as CommandQueryHandler)

func dispatch(dispatchable: Variant) -> Variant:
	var matching_handlers = _handlers.filter(func(handler: CommandQueryHandler) ->bool :
		return handler.can_handle(dispatchable)
	)

	if matching_handlers.size() > 1:
		assert(false, "More than one handler found")
		return

	if matching_handlers.size() == 0:
		assert(false, "No handler found")
		return

	return matching_handlers[0].handle(dispatchable)
