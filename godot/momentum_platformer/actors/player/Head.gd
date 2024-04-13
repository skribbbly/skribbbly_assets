extends Node3D


@onready var player : CharacterBody3D = $".."

@export var mouse_sense := 0.1


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event.is_action("ui_cancel"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		player.rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(50))
