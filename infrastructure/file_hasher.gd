class_name FileHasher
extends Node

const CHUNK_SIZE = 4048

## Implementation stolen from: https://docs.godotengine.org/en/stable/classes/class_hashingcontext.html
func get_file_hash(p_file_path: String) -> String:
	if not FileAccess.file_exists(p_file_path):
		return ''

	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)

	var file = FileAccess.open(p_file_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var remaining = file.get_length() - file.get_position()
		ctx.update(file.get_buffer(min(remaining, CHUNK_SIZE)))
	var res = ctx.finish()

	return res.hex_encode()
