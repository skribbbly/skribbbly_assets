extends Node



@onready var player : CharacterBody3D
@onready var target_cast : RayCast3D
var look_target

var TargetArrow = preload("res://ui/target_arrow.tscn")
var target_arrow = TargetArrow.instantiate()

func _process(delta):
	
	if player.t_state == player.FREE:
		if target_cast.is_colliding():
			
			if look_target == null:
				
				look_target = target_cast.get_collider().get_parent()
				
					
				if look_target != null:
					if look_target.targeted != true:
						
						target_arrow = TargetArrow.instantiate()
						look_target.head_marker.add_child(target_arrow)
						look_target.targeted = true
			
			else:
				if target_cast.get_collider().get_parent() != look_target:
					if look_target.targeted == true:
						target_arrow.queue_free()
						look_target.targeted = false
						look_target = null
			
			
			player.target = look_target
		else:
			if look_target != null:
				look_target.targeted = false
				target_arrow.queue_free()
				look_target = null
			
			player.target = null

