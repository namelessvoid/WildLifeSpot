extends CommandQueryHandler
class_name ProcessedImageHandler

@export
var processed_image_repository: FSProcessedImageRepository

@export
var file_hasher: FileHasher

@export
var exif_reader: ExifReader

func _ready() -> void:
	assert(processed_image_repository)
	assert(file_hasher)

func handle(p_dispatchable: Variant) -> Variant:
	if p_dispatchable is HasImageBeenProcessedQuery:
		return processed_image_repository.has_been_processed(p_dispatchable._image_hash)
	if p_dispatchable is ComputeImageHashQuery:
		return file_hasher.get_file_hash(p_dispatchable._file_path)
	if p_dispatchable is GetExifInfoQuery:
		return exif_reader.GetExifInfo(p_dispatchable._file_paths)

	return null

func can_handle(p_dispatchable: Variant) -> bool:
	return p_dispatchable is HasImageBeenProcessedQuery \
		|| p_dispatchable is ComputeImageHashQuery \
		|| p_dispatchable is GetExifInfoQuery
