extends GdUnitTestSuite

func test_is_initially_not_visible():
	# Arrange
	var runner := scene_runner("res://ui/toast_bar.tscn")

	# Assert
	assert_bool(runner.get_property("visible")).is_false()

func test_show_toast_makes_toast_bar_visible_and_displays_text():
	# Arrange
	var runner := scene_runner("res://ui/toast_bar.tscn")

	# Act
	runner.invoke("show_toast", "This is some text", 3)

	# Assert
	assert_bool(runner.get_property("visible")).is_true()

	var label: Label = runner.find_child("Label")
	assert_str(label.text).is_equal("This is some text")

func test_hides_after_timer_expired():
	# Arrange
	var runner := scene_runner("res://ui/toast_bar.tscn")
	runner.invoke("show_toast", "Foo", 1)
	
	# Act
	await runner.simulate_frames(3, 500)

	# Assert
	assert_bool(runner.get_property("visible")).is_false()
