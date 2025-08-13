extends GdUnitTestSuite

const Repository = preload("res://infrastructure/sqlite_fs_processed_image_repository.gd")

func _create_repository() -> FSProcessedImageRepository:
	var repository: Repository = auto_free(Repository.new())
	repository.set_db_path(":memory:")
	return repository

func test_has_been_processed_returns_false_if_hash_is_not_marked_as_processed():
	var repository := _create_repository()
	assert_bool(repository.has_been_processed("some-file-hash")).is_false()

func test_has_been_processed_returns_true_if_hash_is_marked_as_processed():
	var repository := _create_repository()
	repository.mark_processed("some-file-hash")
	assert_bool(repository.has_been_processed("some-file-hash")).is_true()
