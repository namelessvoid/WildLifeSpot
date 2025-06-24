extends Node

## Shows a native FileDialog to selecte a directory.
## The provided callback is called with the selected directory
## on success.
func show_dir_dialog(p_on_dir_selected_callback: Callable):
	var dialog := FileDialog.new()
	add_child(dialog)
	dialog.use_native_dialog = true
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.dir_selected.connect(func(p_dir: String):
		p_on_dir_selected_callback.call(p_dir)
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered_ratio(0.8)
