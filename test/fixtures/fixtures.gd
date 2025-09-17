extends RefCounted
class_name TestFixtures

static var image_path1: String:
	get: return ProjectSettings.globalize_path("res://test/fixtures/fixture_image1.jpg")

static var image_path2: String:
	get: return ProjectSettings.globalize_path("res://test/fixtures/fixture_image2.jpg")
