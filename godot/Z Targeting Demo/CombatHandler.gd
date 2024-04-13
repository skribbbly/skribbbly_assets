extends Node

var player
var target_cast
var look_target
var active_target


var TargetArrow = preload("res://ui/ui_target_arrow.tscn")
var target_arrow = TargetArrow.instantiate()

var Retical = preload("res://ui/retical.tscn")
var retical = Retical.instantiate()

func _process(delta):
	if target_cast.is_colliding():
		if target_cast.get_collider().get_parent().is_in_group("Targetable"):
			if look_target == null:
				look_target = target_cast.get_collider().get_parent()
				if look_target.looked_at != true:
					target_arrow = TargetArrow.instantiate()
					look_target.head_marker.add_child(target_arrow)
					look_target.looked_at = true
			else:
				if target_cast.get_collider().get_parent() != look_target:
					if look_target.looked_at == true:
						target_arrow.queue_free()
						look_target.looked_at = false
						look_target = null
	else:
		if look_target != null:
			target_arrow.queue_free()
			look_target.looked_at = false
			look_target = null
	
	if look_target != null:
		player.target = look_target
	
	if look_target != null:
		if look_target.head_marker.get_child_count() != 0:
			target_arrow.position = get_viewport().get_camera_3d().unproject_position(look_target.head_marker.global_transform.origin)
	
	if player.target_state == player.TARGETING:
		if look_target != null:
			look_target.targeted = true
