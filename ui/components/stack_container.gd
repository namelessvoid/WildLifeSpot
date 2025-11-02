extends Control
class_name StackContainer

@onready var _children_container: Control = %ChildrenContainer
@onready var _bread_crumbs_container: Control = %BreadCrumbsContainer

func push(p_name: String, p_child: Control):
	if _children_container.get_child_count() > 0:
		_children_container.get_child(-1).visible = false
	_children_container.add_child(p_child)
	p_child.size_flags_vertical = Control.SIZE_EXPAND_FILL

	_push_breadcrumb(p_name)

func pop():
	if _children_container.get_child_count() == 0:
		return

	var last_child = _children_container.get_child(-1)
	_children_container.remove_child(last_child)
	last_child.queue_free()

	if _children_container.get_child_count() > 0:
		_children_container.get_child(-1).visible = true

	_pop_breadcrumb()

func clear():
	for child in _children_container.get_children():
		child.queue_free()
		remove_child(child)

	for child in _bread_crumbs_container.get_children():
		child.queue_free()
		_bread_crumbs_container.remove_child(child)

func _ready() -> void:
	assert(_bread_crumbs_container)
	assert(_children_container)

	clear()

func _push_breadcrumb(p_name: String) -> void:
	if _bread_crumbs_container.get_child_count() > 0:
		var current_last_button: LinkButton = _bread_crumbs_container.get_child(-1)
		current_last_button.disabled = false

		var separator := Label.new()
		separator.text = "/"
		_bread_crumbs_container.add_child(separator)
	
	var link_button := LinkButton.new()
	link_button.text = p_name
	link_button.disabled = true
	link_button.pressed.connect(pop)
	_bread_crumbs_container.add_child(link_button)

func _pop_breadcrumb() -> void:
	var number_of_children_to_pop: int = min(2, _bread_crumbs_container.get_child_count())
	for i in range(number_of_children_to_pop):
		var child := _bread_crumbs_container.get_child(-1)
		_bread_crumbs_container.remove_child(child)
		child.queue_free()

	if _bread_crumbs_container.get_child_count() > 0:
		var last_button: LinkButton = _bread_crumbs_container.get_child(-1)
		last_button.disabled = true
