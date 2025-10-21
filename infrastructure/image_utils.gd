class_name ImageUtils
extends Node

static func load_inverted(file_path: String) -> Texture2D:
	var image := Image.load_from_file(file_path)
	for x in image.get_width():
		for y in image.get_height():
			var previous_color = image.get_pixel(x, y)
			var new_color = Color.WHITE - previous_color
			new_color.a = previous_color.a
			image.set_pixel(x, y, new_color)
	return ImageTexture.create_from_image(image)
