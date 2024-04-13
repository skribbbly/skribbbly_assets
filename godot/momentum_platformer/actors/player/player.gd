extends CharacterBody3D


@export_category("Movement")

@export var speed := 10.0
@export var accel := 1.0
@export var friction := 5.0

@export var jump_height := 10.0
@export var gravity := 9.8

@onready var mesh = $Mesh


var direction := Vector3()
var move_vector := Vector3()
var gravity_vector := Vector3()


func _ready():
	mesh.top_level = true

func _process(delta):
	mesh.global_transform.origin = global_transform.origin
	if direction != Vector3.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 10 * delta)

func _physics_process(delta):
	var h_rot = global_transform.basis.get_euler().y
	var input_vector := Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector3(input_vector.x, 0, input_vector.y).rotated(Vector3.UP, h_rot).normalized()
	
	if input_vector != Vector2.ZERO:
		move_vector = move_vector.lerp(direction * speed, accel * delta)
	else:
		move_vector = move_vector.lerp(Vector3.ZERO, friction * delta)
	
	if not is_on_floor():
		gravity_vector.y -= gravity * delta
	else:
		gravity_vector.y = 0
	
	velocity = move_vector + gravity_vector
	
	var get_normal_rotation = Vector3(rotation_degrees.x, rotation_degrees.y, 0)
	
	
	move_and_slide()
	
	get_normal_rotation = get_floor_normal()
	
	$CollisionShape3D.rotation = get_normal_rotation
	#mesh.rotation = get_normal_rotation
