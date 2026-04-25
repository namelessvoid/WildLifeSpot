extends GutTest

func _create_handler() -> AnimalSpotReportQueryHandler:
	var temp_file := FileAccess.create_temp(FileAccess.WRITE_READ, "wildlifespot_gut", ".db")
	var handler := AnimalSpotReportQueryHandler.new()
	add_child_autofree(handler)
	handler.SetDbPath(temp_file.get_path_absolute())
	return handler

func test_returns_empty_report_if_granularity_is_wrong():
	# Arrange
	var handler := _create_handler()

	# Act
	var query := AnimalSpotReportQuery.new()
	query.ReportOptions.DateFilter = "asd"
	var report: AnimalSpotReport = handler.Handle(query)

	await wait_process_frames(1)

	# Assert
	assert_eq(report.MaxCount, 0)
	assert_engine_error("Received invalid query. Returning empty report.")
