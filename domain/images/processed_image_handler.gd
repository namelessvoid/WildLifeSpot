extends CommandQueryHandler
class_name ProcessedImageHandler

@export
var processed_image_repository: FSProcessedImageRepository

@export
var file_hasher: FileHasher

func _ready() -> void:
	assert(processed_image_repository)
	assert(file_hasher)

func handle(p_dispatchable: Variant) -> Variant:
	if p_dispatchable is HasImageBeenProcessedQuery:
		return processed_image_repository.has_been_processed(p_dispatchable._image_hash)
	if p_dispatchable is ComputeImageHashQuery:
		return _compute_image_hash(p_dispatchable)

	return null

func can_handle(p_dispatchable: Variant) -> bool:
	return p_dispatchable is HasImageBeenProcessedQuery \
		|| p_dispatchable is ComputeImageHashQuery

func _compute_image_hash(p_query: ComputeImageHashQuery) -> String:
	return file_hasher.get_file_hash(p_query._file_path)
