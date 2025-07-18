extends RefCounted

var _return_values: Array[Dictionary] = []

func with_query(p_query_type: Variant, p_return_value: Variant):
	_return_values.append({
		"type": p_query_type,
		"return_value": p_return_value
	})
	return self

func with_command(p_command_type: Variant):
	_return_values.append({
		"type": p_command_type,
		"return_value": null
	})
	return self

func build() -> CommandQueryHandler:
	return MockCommandQueryHandler.new(_return_values)

class MockCommandQueryHandler:
	extends CommandQueryHandler

	var _return_values: Array[Dictionary]
	var calls: Array[Variant]

	func _init(p_return_values: Array[Dictionary]):
		_return_values = p_return_values

	func can_handle(p_dispatchable: Variant) -> bool:
		return true

	func handle(p_dispatchable: Variant) -> Variant:
		assert(_return_values.size() > 0, "MockCommandQueryHandler: Received call but did not expect any more calls")
		assert(
			p_dispatchable.get_script() == _return_values[0]["type"],
			"MockCommandQueryHandler: Called with unexpected Dispatchable of type %s. Expected type: %s"
				% [p_dispatchable.get_script().resource_path, _return_values[0]["type"].resource_path]
		)

		calls.append(p_dispatchable)

		var return_value = _return_values[0]["return_value"]
		_return_values.remove_at(0)
		return return_value
