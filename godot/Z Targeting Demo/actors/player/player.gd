extends CharacterBody3D


@export_category("Movement")
@export var walk_speed : float = 1.5
@export var run_speed : float = 1.8
@export var accel : float = 10.0
@export var walk_friction : float = 10.0
@export var sprint_friction : float = 5.0

var speed
var friction

@export_category("Camera Control")
@export_group("Mouse")
@export var mouse_sensitivity := 0.1

# ---- Onready ----
@onready var mesh := $Mesh
@onready var head := $Head
@onready var anim := $AnimationTree
@onready var sprinttimer = $SprintTimer
var sprintable = false


# ---- Bool ----
var ground_snap : bool
var targetable_object := false
var sprinting := false
# ---- Vector3 ----
var direction : Vector3 = Vector3()
var gravity_vec : Vector3 = Vector3()
var move_vec : Vector3 = Vector3()
var input_vector : Vector2
# ---- Animation ----
var anim_blend : float = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	speed = walk_speed
	friction = walk_friction
	mesh.top_level = true

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta) -> void:
	mesh.global_transform.origin = global_transform.origin
	
	#turns body in the direction of movement
	if direction != Vector3.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 10 * delta)
	



func _physics_process(delta) -> void:
	
	if sprinting == true:
		speed = run_speed
		friction = sprint_friction
		anim.set("parameters/RunTransition/transition_request", "Sprint")
	else:
		speed = walk_speed
		anim.set("parameters/RunTransition/transition_request", "Walk")
		
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	direction = Vector3.ZERO
	
	var h_rot = global_transform.basis.get_euler().y  
	
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector3(input_vector.x, 0, input_vector.y).rotated(Vector3.UP, h_rot).normalized()
	
	if input_vector != Vector2.ZERO:
		sprintable = true
		if anim_blend < 1: anim_blend += 0.1
		anim.set("parameters/Blend2/blend_amount", anim_blend)
		move_vec = move_vec.lerp(direction * speed, accel * delta)
		if Input.is_action_just_pressed("shift"):
			sprinting = not sprinting
	else:
		if anim_blend != 0: 
			anim_blend -= 0.1
			if anim_blend < 0: anim_blend = 0 
		anim.set("parameters/Blend2/blend_amount", anim_blend)
		if sprintable == true:
			sprinttimer.start()
			sprintable = false
		move_vec = move_vec.lerp(Vector3.ZERO, friction * delta)
	
	if not is_on_floor():
		gravity_vec.y -= 9.8 * delta
	else:
		gravity_vec = Vector3.ZERO
	
	velocity = move_vec + gravity_vec
	
	if velocity == Vector3.ZERO:
		friction = walk_friction
	
	move_and_slide()
	


func _on_sprint_timer_timeout():
	if input_vector == Vector2.ZERO:
		sprinting = false
	
