extends Control
class_name ImageViewer

signal request_save_image

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _camera: Camera2D = %Camera2D
@onready var _zoom_in_button: Button = %ZoomInButton
@onready var _zoom_out_button: Button = %ZoomOutButton
@onready var _save_image_button: Button = %SaveImageButton

func _ready():
	assert(_sprite)
	assert(_camera)
	assert(_zoom_in_button)
	assert(_zoom_out_button)

	_zoom_in_button.pressed.connect(zoom_in)
	_zoom_out_button.pressed.connect(zoom_out)
	_save_image_button.pressed.connect(request_save_image.emit)

func set_texture(p_texture: Texture2D):
	_sprite.texture = p_texture
	_camera.zoom = Vector2.ONE
	_camera.offset = Vector2.ZERO

	var texture_size = p_texture.get_size()
	var texture_aspect := p_texture.get_size().x / p_texture.get_size().y

	_sprite.offset = texture_size / 2

	var texture_scale: float
	if texture_aspect >= 1:
		texture_scale = size.y / texture_size.y 
	else:
		texture_scale = size.x / texture_size.x
	_sprite.scale = Vector2(texture_scale, texture_scale)

func zoom_in():
	_camera.zoom += Vector2(0.25, 0.25)

func zoom_out():
	_camera.zoom -= Vector2(0.25, 0.25)
	if _camera.zoom.x < 1:
		_camera.zoom = Vector2.ONE

func _gui_input(p_event: InputEvent) -> void:
	var mouse_motion := p_event as InputEventMouseMotion
	if mouse_motion != null:
		var lmb_pressed := mouse_motion.button_mask & MOUSE_BUTTON_LEFT
		if !lmb_pressed:
			return
		_camera.offset -= mouse_motion.relative / _camera.zoom
	
	var mouse_input := p_event as InputEventMouseButton
	if mouse_input != null:
		if mouse_input.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		if mouse_input.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
