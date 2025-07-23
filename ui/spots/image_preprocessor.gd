extends Node

signal progress_changed(p_progress: float)

func pre_process(
	p_file_paths: PackedStringArray,
	p_skip_already_processed_files: bool,
	p_group_into_quarters: bool
) -> Array[Dictionary]:
	var file_paths := p_file_paths
	if p_skip_already_processed_files:
		file_paths = await _filter_already_processed_files(p_file_paths)

	var bucket_length_in_seconds = 1
	if p_group_into_quarters:
		bucket_length_in_seconds = 15 * 60
	var file_path_with_time_buckts := _get_file_paths_with_time_bucket(file_paths, bucket_length_in_seconds)

	file_path_with_time_buckts.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["bucket"] == b["bucket"]:
			return a["file_path"] < b["file_path"]
		return a["bucket"] < b["bucket"]
	)
	return file_path_with_time_buckts

func _filter_already_processed_files(p_file_paths: PackedStringArray):
	var files := Array(p_file_paths)\
	.map(func(path: String) -> Dictionary[String, Variant]:
		return { "path": path, "hash": "" }
	)

	var group_id := WorkerThreadPool.add_group_task(func(index: int) -> void:
		var hash_query := ComputeImageHashQuery.new(files[index]["path"])
		files[index]["hash"] = CommandQueryDispatcher.dispatch(hash_query)
	, files.size())

	progress_changed.emit(0)
	if files.size() > 100:
		while !WorkerThreadPool.is_group_task_completed(group_id):
			var processed = WorkerThreadPool.get_group_processed_element_count(group_id)
			progress_changed.emit(processed / float(files.size()) * 100.0)
			if processed < files.size():
				await get_tree().create_timer(1).timeout

	WorkerThreadPool.wait_for_group_task_completion(group_id)

	files = files.filter(func(f: Dictionary) -> bool:
		var query = HasImageBeenProcessedQuery.new(f["hash"])
		return !CommandQueryDispatcher.dispatch(query)
	)

	var file_paths = PackedStringArray(
		files.map(func(f) -> String: return f["path"])
	)
	return file_paths

func _get_file_paths_with_time_bucket(
	p_file_paths: PackedStringArray,
	p_bucket_length_in_seconds: int
) -> Array[Dictionary]:
	var time_buckets: Array[Dictionary] = []
	var exif_query = GetExifInfoQuery.new(p_file_paths)
	var exif_infos: Dictionary[String, ExifInfo] = CommandQueryDispatcher.dispatch(exif_query)
	for file_path in p_file_paths:
		var exif_info: ExifInfo = exif_infos.get(file_path, null)

		var unix_time: int = -1
		if exif_info != null:
			unix_time = Time.get_unix_time_from_datetime_string(exif_info.DateTime)

		var bucket: int = unix_time - (unix_time % p_bucket_length_in_seconds)
		time_buckets.append({
			"bucket": bucket,
			"file_path": file_path
		})

	return time_buckets
