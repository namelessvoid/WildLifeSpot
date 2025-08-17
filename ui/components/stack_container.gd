extends Control
class_name StackContainer

func push(p_child: Control):
	if get_child_count() > 0:
		get_child(-1).visible = false
	add_child(p_child)
	p_child.set_anchors_preset(Control.PRESET_FULL_RECT)

func	 pop():
	if get_child_count() == 0:
		return

	var last_child = get_child(-1)
	remove_child(last_child)
	last_child.queue_free()

	if get_child_count() > 0:
		get_child(-1).visible = true
