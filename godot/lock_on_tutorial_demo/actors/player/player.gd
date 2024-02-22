extends CharacterBody3D

@export_category("Movement")
@export var walk_speed : float = 2.0
@export var run_speed : float = 6.52
@export var accel : float = 10.0
@export var friction : float = 10.0

var speed

@export_category("Camera Control")
@export_group("Mouse")
@export var mouse_sensitivity : float = 0.1

enum {
	FREE,
	TARGETING
}

# ---- Loads ----
# ---- Onready ----
@onready var mesh := $Mesh
@onready var head := $Head
@onready var anim := $AnimationTree
@onready var target_cast := $Head/RayCast3D

@onready var pcam := %FreeCamera
@onready var bcam := %BattleCamera


# ---- Bool ----
var ground_snap : bool
var targetable_object : bool = false

# ---- Vector3 ----
var direction : Vector3 = Vector3()
var gravity_vec : Vector3 = Vector3()
var move_vec : Vector3 = Vector3()


# ---- Animation ----
var anim_blend : float = 0
var anim_vec = Vector2()

# ---- Signals ----


var t_state = FREE

var target

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	CombatHandle.player = self
	CombatHandle.target_cast = target_cast
	speed = walk_speed
	mesh.top_level = true

func _input(event):
	
	if t_state == FREE:
		if event is InputEventMouseMotion:
			var pcam_rotation_degrees: Vector3
			pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
			pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
			pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, -89, 89)
			head.rotation_degrees.x = clampf(pcam_rotation_degrees.x, 0, 89)
			pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
			rotation_degrees.y = pcam_rotation_degrees.y
			pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, 0, 360)
			pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
			
	else:
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.y = rotation_degrees.y
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

func _process(delta) -> void:
	var bcam_rotation_degrees: Vector3
	bcam_rotation_degrees = bcam.get_third_person_rotation_degrees()
	bcam_rotation_degrees.y = rotation_degrees.y
	bcam.set_third_person_rotation_degrees(bcam_rotation_degrees)
	
	mesh.global_transform.origin = global_transform.origin
	
	#turns body in the direction of movement
	if direction != Vector3.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), 10 * delta)
	



func _physics_process(delta) -> void:
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	
	direction = Vector3.ZERO
	
	var h_rot = global_transform.basis.get_euler().y  
	
	match t_state:
		FREE:
			bcam.set_priority(0)
			
			if Input.is_action_just_pressed("mid click") and target != null:
				t_state = TARGETING
		TARGETING:
			if target == null:
				t_state = FREE
			else:
				bcam.set_priority(2)
				var pcam_rotation_degrees: Vector3
				look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
				
				if Input.is_action_just_pressed("mid click"):
					t_state = FREE
	
	if target != null:
		var targets :Array = [target, self]
		bcam.set_look_at_group_node_array(targets)
	
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector3(input_vector.x, 0, input_vector.y).rotated(Vector3.UP, h_rot).normalized()
	
	
	
	if input_vector != Vector2.ZERO:
		if anim_blend < 1: anim_blend += 0.1
		anim.set("parameters/RunBlend/blend_amount", anim_blend)
		move_vec = move_vec.lerp(direction * speed, accel * delta)
	else:
		if anim_blend != 0: 
			anim_blend -= 0.1
			if anim_blend < 0: anim_blend = 0 
		anim.set("parameters/RunBlend/blend_amount", anim_blend)
		move_vec = move_vec.lerp(Vector3.ZERO, friction * delta)
	
	
	if not is_on_floor():
		gravity_vec.y -= 9.8 * delta
	else:
		gravity_vec = Vector3.ZERO
	
	velocity = move_vec + gravity_vec
	
	move_and_slide()
	


func _on_target_detector_area_entered(area):
	if area.get_parent() == target:
		target = area.get_parent()


func _on_target_detector_area_exited(area):
	if area.get_parent() == target:
		target = null
