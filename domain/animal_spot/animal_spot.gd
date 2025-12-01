extends RefCounted
class_name AnimalSpot

const SOURCE_CAMERA_IMAGE = "CAMERA_IMAGE"
const SOURCE_HUMAN_SEEN = "HUMAN_SEEN"
const SOURCE_HUMAN_HEARED = "HUMAN_HEARED"
const SOURCES: Array[String] = [
	SOURCE_CAMERA_IMAGE,
	SOURCE_HUMAN_SEEN,
	SOURCE_HUMAN_HEARED
]


var _id: int = -1
var source: String = SOURCE_CAMERA_IMAGE
var file_path: String
var camera_id: int
var spotted_at: String
var animal_name: String
var animal_count: int
