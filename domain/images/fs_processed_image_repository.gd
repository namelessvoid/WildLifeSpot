@abstract
class_name FSProcessedImageRepository
extends Node

@abstract
func has_been_processed(file_hash: String) -> bool

@abstract
func mark_processed(file_hash: String) -> void
