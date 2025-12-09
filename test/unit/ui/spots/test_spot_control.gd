extends GutTest

var _spot_control_scene := load("uid://x443c3b32aeo")

const CommandQueryHandlerGenerator = preload("uid://dqluc8bbxxlpj")
const SpotControl = preload("uid://cmcpbtxk0apc6")
const SpotControlPage := preload("uid://cvk8uidrqc63j")
const CameraGenerator = preload("uid://bo81kvem0fusc")


func test_should_initialize_empty():
	# Arrange
	var mock_handler: CommandQueryHandler = add_child_autofree(CommandQueryHandlerGenerator.new()
		.with_query(FindAllCamerasQuery, [])
		.build()
	)
	CommandQueryDispatcher._handlers = [mock_handler]

	# Act
	var spot_control = _spot_control_scene.instantiate()
	add_child_autofree(spot_control)

	# Assert
	var spot_control_page = SpotControlPage.new(spot_control)
	assert_eq(spot_control_page.get_date(), "")
	assert_eq(spot_control_page.get_time(), "")
	assert_eq(spot_control_page.get_source_option(), AnimalSpot.SOURCE_CAMERA_IMAGE)
	assert_eq(spot_control_page.get_camera_id(), -1)
	assert_eq(spot_control_page.animal_box_count(), 1)

func test_should_allow_to_add_and_remove_animal_boxes():
	# Arrange
	var mock_handler: CommandQueryHandler = add_child_autofree(CommandQueryHandlerGenerator.new()
		.with_query(FindAllCamerasQuery, [])
		.build()
	)
	CommandQueryDispatcher._handlers = [mock_handler]

	var spot_control: SpotControl = _spot_control_scene.instantiate()
	add_child_autofree(spot_control)

	var spot_control_page := SpotControlPage.new(spot_control)

	# Act
	spot_control_page.press_add_animal_box_button()
	spot_control_page.press_add_animal_box_button()
	spot_control_page.press_remove_animal_box_button(1)

	# Assert
	assert_eq(spot_control_page.animal_box_count(), 3)
