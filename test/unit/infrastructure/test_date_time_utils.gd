extends GutTest

func test_is_valid_date_returns_correct_result(params=use_parameters([
	["2025", false],
	["2025-13-01", false],
	["2025-01-32", false],
	["2025-001-01", false],
	["2025-01-001", false],
	["f", false],
	[" ", false],
	["2025-01", true],
	["2025-01-01", true]
])):
	# Arrange
	var date_string = params[0]
	var expected_result = params[1]

	# Act
	var actual_result = DateTimeUtils.IsValidDate(date_string)

	# Assert
	assert_eq(actual_result, expected_result)

func test_parse_date(params=use_parameters([
	["2025-01-01", "2025-01-01"],
	["2025-01", "2025-01-01"]
])):
	# Arrange
	var date_string = params[0]
	var expected_result = params[1]

	# Act
	var actual_result = DateTimeUtils.ParseDate(date_string)

	# Assert
	assert_eq(actual_result, expected_result)

func test_is_valid_time(params=use_parameters([
	["00", false],
	["00:00", true],
	["00:00:00", true],
	["0:0", true],
	["0:0:0", true]
])):
	# Arrange
	var time_string = params[0]
	var expected_result = params[1]

	# Act
	var actual_result = DateTimeUtils.IsValidTime(time_string)

	# Assert
	assert_eq(actual_result, expected_result)

func test_parse_time(params=use_parameters([
	["00:00", "00:00:00"],
	["00:00:00", "00:00:00"],
	["0:0", "00:00:00"],
	["0:0:0", "00:00:00"]
])):
	# Arrange
	var time_string = params[0]
	var expected_result = params[1]

	# Act
	var actual_result = DateTimeUtils.ParseTime(time_string)

	# Assert
	assert_eq(actual_result, expected_result)
