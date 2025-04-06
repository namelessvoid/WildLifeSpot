extends GutTest

const Repository = preload("res://infrastructure/sqlite_fs_processed_image_repository.gd")

func _create_repository() -> FSProcessedImageRepository:
	var repository := Repository.new()
	repository._db_path = ":memory:"
	add_child_autofree(repository)
	return repository

func test_has_been_processed_returns_false_if_hash_is_not_marked_as_processed():
	var repository := _create_repository()
	assert_false(repository.has_been_processed("some-file-hash"))

func test_has_been_processed_returns_true_if_hash_is_marked_as_processed():
	var repository := _create_repository()
	repository.mark_processed("some-file-hash")
	assert_true(repository.has_been_processed("some-file-hash"))
