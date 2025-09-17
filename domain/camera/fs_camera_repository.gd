@abstract
class_name FSCameraRepository
extends Node

@warning_ignore("unused_signal")
signal db_changed

@abstract
func find_all() -> Array[FSCamera]

@abstract
func save(p_camera: FSCamera) -> void

@abstract
func delete(p_id: int) -> void
