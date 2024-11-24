extends Node3D

@export_category("Camera Control")
@export_group("Mouse")
@export var mouse_sensitivity : float

@onready var player = $".."

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		player.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
