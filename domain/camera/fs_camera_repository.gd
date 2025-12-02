@abstract
class_name FSCameraRepository
extends Node

@abstract
func find_all() -> Array[FSCamera]

@abstract
func save(p_camera: FSCamera) -> void

@abstract
func delete(p_id: int) -> void
