extends GutTest

const ToastBar := preload("res://ui/toast_bar.gd")

var toast_bar_scene: PackedScene = preload("res://ui/toast_bar.tscn")

func test_is_initially_not_visible():
	# Arrange
	var toast_bar: ToastBar = toast_bar_scene.instantiate()

	# Act
	add_child_autofree(toast_bar)

	# Assert
	assert_false(toast_bar.visible)

func test_show_toast_makes_toast_bar_visible_and_displays_text():
	# Arrange
	var toast_bar: ToastBar = toast_bar_scene.instantiate()
	add_child_autofree(toast_bar)

	# Act
	toast_bar.show_toast("This is some text", 3)

	# Assert
	assert_true(toast_bar.visible)
	assert_eq(toast_bar.get_node("%Label").text, "This is some text")

func test_hides_after_timer_expired():
	# Arrange
	var toast_bar: ToastBar = toast_bar_scene.instantiate()
	add_child_autofree(toast_bar)
	toast_bar.show_toast("Foo", 1)

	# Act
	await wait_for_signal(toast_bar.visibility_changed, 2)

	# Assert
	assert_false(toast_bar.visible)
