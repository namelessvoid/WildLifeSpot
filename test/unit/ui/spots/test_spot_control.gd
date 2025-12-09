extends GutTest

var _spot_control_scene := load("uid://x443c3b32aeo")

const CommandQueryHandlerGenerator = preload("uid://dqluc8bbxxlpj")
const SpotControl = preload("uid://cmcpbtxk0apc6")
const SpotControlPage := preload("uid://cvk8uidrqc63j")
const CameraGenerator = preload("uid://bo81kvem0fusc")


func test_init_should_initialize_empty():
	# Arrange
	var spot_control = _spot_control_scene.instantiate()
	add_child_autofree(spot_control)

	# Assert
	var spot_control_page = SpotControlPage.new(spot_control)
	assert_eq(spot_control_page.get_date(), "")
	assert_eq(spot_control_page.get_time(), "")
	assert_eq(spot_control_page.get_selected_source_label(), AnimalSpot.SOURCE_CAMERA_IMAGE)
	assert_eq(spot_control_page.get_selected_camera_id(), -1)
	assert_eq(spot_control_page.animal_box_count(), 1)

func test_init_should_initialize_source_options():
	# Act
	var spot_control = _spot_control_scene.instantiate()
	add_child_autofree(spot_control)

	# Assert
	var spot_control_page = SpotControlPage.new(spot_control)
	assert_eq_deep(
		spot_control_page.get_all_source_labels(),
		[AnimalSpot.SOURCE_CAMERA_IMAGE, AnimalSpot.SOURCE_HUMAN_SEEN, AnimalSpot.SOURCE_HUMAN_HEARED]
	)

func test_reset_should_initialize_camera_options():
	# Arrange
	var camera1: FSCamera = CameraGenerator.new().with_id(12).with_name("Camera 1").build()
	var camera2: FSCamera = CameraGenerator.new().with_id(14).with_name("Camera 2").build()
	var mock_handler: CommandQueryHandler = add_child_autofree(CommandQueryHandlerGenerator.new()
		.with_query(FindAllCamerasQuery, [camera1, camera2] as Array[FSCamera])
		.build()
	)
	CommandQueryDispatcher._handlers = [mock_handler]

	var spot_control = _spot_control_scene.instantiate()
	add_child_autofree(spot_control)

	# Act
	spot_control.reset()

	# Assert
	var spot_control_page = SpotControlPage.new(spot_control)
	assert_eq_deep(
		spot_control_page.get_all_camera_labels(),
		["Camera 1", "Camera 2"]
	)
	assert_eq(spot_control_page.get_selected_camera_id(), 12)

func test_should_allow_to_add_and_remove_animal_boxes():
	# Arrange
	var mock_handler: CommandQueryHandler = add_child_autofree(CommandQueryHandlerGenerator.new()
		.with_query(FindAllCamerasQuery, [] as Array[FSCamera])
		.build()
	)
	CommandQueryDispatcher._handlers = [mock_handler]

	var spot_control: SpotControl = _spot_control_scene.instantiate()
	add_child_autofree(spot_control)
	spot_control.reset()

	var spot_control_page := SpotControlPage.new(spot_control)

	# Act
	spot_control_page.press_add_animal_box_button()
	spot_control_page.press_add_animal_box_button()
	spot_control_page.press_remove_animal_box_button(1)

	# Assert
	assert_eq(spot_control_page.animal_box_count(), 3)
