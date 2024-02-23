extends CharacterBody3D


enum{
	FREE,
	TARGETING
}

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
@export var min_yaw: float = -89.9
@export var max_yaw: float = 50

@export var min_pitch: float = 0
@export var max_pitch: float = 360

# ---- Onready ----
@onready var mesh := $Mesh
@onready var head := $Head
@onready var anim := $AnimationTree
@onready var target_cast = $Head/TargetCast
@onready var sprinttimer = $SprintTimer
@onready var pcam = %FreeCam
@onready var bcam = %BattleCam

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


var target 

var target_state = FREE

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	CombatHandler.player = self
	CombatHandler.target_cast = target_cast
	speed = walk_speed
	friction = walk_friction
	mesh.top_level = true



func _input(event):
	var pcam_rotation_degrees: Vector3
	# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
	pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
	if event is InputEventMouseMotion:
		if target_state == FREE:
			pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
			pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_yaw, max_yaw)
			head.rotation_degrees.x = clampf(pcam_rotation_degrees.x, 0, max_yaw)
			pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
			self.rotation_degrees.y = pcam_rotation_degrees.y
			pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_pitch, max_pitch)
			pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
		else:
			pcam_rotation_degrees.y = rotation_degrees.y
			pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)



func _process(delta) -> void:
	mesh.global_transform.origin = global_transform.origin
	
	var bcam_rotation_degrees: Vector3
	bcam_rotation_degrees = bcam.get_third_person_rotation_degrees()
	bcam_rotation_degrees.y = rotation_degrees.y
	bcam.set_third_person_rotation_degrees(bcam_rotation_degrees)
	
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
	
	match target_state:
		FREE:
			bcam.set_priority(0)
			
			if target != null:
				if Input.is_action_just_pressed("mid_click"):
					target_state = TARGETING
			
		TARGETING:
			if target != null:
				bcam.set_priority(2)
				look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
				if Input.is_action_just_pressed("mid_click"):
					target_state = FREE
			else:
				target_state = FREE
	
	
	if target != null:
		var targets :Array[Node3D] = [target, self]
		bcam.set_look_at_group_node_array(targets)
	
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
	




func _on_area_3d_area_exited(area):
	if area.get_parent() == target:
		target = null


func _on_area_3d_area_entered(area):
	if area.get_parent() == target:
		target = area.get_parent()
