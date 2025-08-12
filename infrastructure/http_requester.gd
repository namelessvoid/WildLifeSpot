extends Node
class_name HTTPRequester

func do_get(host: String, url: String, headers: PackedStringArray = []) -> HTTPResponse:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request(host + url, headers)
	var result := await http_request.request_completed as Array

	http_request.queue_free()
	
	var status_code: int = result[1]
	var response_headers: PackedStringArray = result[2]
	var raw_body: PackedByteArray = result[3]

	if status_code == 307  || status_code == 308:
		var redirect_location: String
		for header in response_headers:
			if !header.to_lower().begins_with("location:"):
				continue
			redirect_location = header.replace("Location: ", "")
		return await do_get(host, redirect_location, headers)

	return HTTPResponse.new(status_code, raw_body)

class HTTPResponse:
	var body: PackedByteArray
	var status_code: int

	func _init(p_status_code: int, p_body: PackedByteArray):
		body = p_body
		status_code = p_status_code

	func json_body_to_dict() -> Dictionary:
		return JSON.parse_string(body.get_string_from_utf8())
