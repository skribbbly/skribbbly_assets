extends CharacterBody3D


var speed
@export var walk_speed : float = 5.0


var direction : Vector3 = Vector3.ZERO
var move_vec : Vector3 = Vector3.ZERO
var gravity_vec : Vector3 = Vector3.ZERO

#@onready var mesh : Node3D = $test_actor
#@onready var forward : Node3D = $Forward


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#mesh.top_level = true
	#forward.top_level = true


func _process(delta):
	#mesh.global_transform.origin = global_transform.origin
	#forward.global_transform.origin = global_transform.origin
	
	#if direction != Vector3.ZERO:
		#mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 20 * delta)
	#forward.rotation.y = mesh.rotation.y
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta) -> void:
	var h_rot = global_transform.basis.get_euler().y
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vec.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector3(input_vec.x, 0, input_vec.y).rotated(Vector3.UP, h_rot).normalized()
	
	if input_vec != Vector2.ZERO:
		move_vec = direction * walk_speed
	else:
		move_vec = Vector3.ZERO
	
	if not is_on_floor():
		gravity_vec.y += -9.8 * delta
	else:
		gravity_vec.y = 0
	
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#gravity_vec.y += 3
	
	velocity = move_vec + gravity_vec
	
	move_and_slide()
