extends Node
class_name HTTPRequester

func do_get(p_full_url: String, p_headers: PackedStringArray = []) -> HTTPResponse:
	var http_request := HTTPRequest.new()
	add_child(http_request)

	http_request.request(p_full_url, p_headers)
	var result := await http_request.request_completed as Array

	http_request.queue_free()
	return HTTPResponse.new(result[1], result[3], result[2])

func do_get_with_redirect(p_host: String, p_path: String, p_headers: PackedStringArray = []) -> HTTPResponse:
	var http_response := await do_get(p_host + p_path, p_headers)

	if http_response.is_redirect():
		var redirect_location := http_response.find_header_value("Location")
		return await do_get(p_host + redirect_location, p_headers)

	return http_response


class HTTPResponse:
	var body: PackedByteArray
	var status_code: int
	var headers: PackedStringArray

	func _init(p_status_code: int, p_body: PackedByteArray, p_headers: PackedStringArray):
		body = p_body
		status_code = p_status_code
		headers = p_headers

	func json_body_to_dict() -> Dictionary:
		return JSON.parse_string(body.get_string_from_utf8())

	func is_redirect() -> bool:
		return status_code == 307 || status_code == 300

	func find_header_value(p_header_name: String) -> String:
		var header_name_lower := p_header_name.to_lower()
		for header in headers:
			var header_lower := header.to_lower()
			if header_lower.begins_with(header_name_lower):
				return header_lower.replace(header_name_lower + ": ", "")
		return ""
