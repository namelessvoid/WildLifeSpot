extends Control

const _animal_pictogram_search_scene := preload("res://ui/animal_pictogram_search/animal_pictogram_search.tscn")

@onready var _stack_container: StackContainer = $StackContainer

func _ready() -> void:
	$StackContainer/VBoxContainer/PhylopicButton.pressed.connect(func():
		var scene := _animal_pictogram_search_scene.instantiate()
		_stack_container.push(scene)
	)
