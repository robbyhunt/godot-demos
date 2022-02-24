extends RayCast

onready var crosshair = get_parent().get_node("Crosshair")

var mass_limit = 50
var throw_force = 5

var is_hovering = false
var object_grabbed = null
var return_collision_layer_bit = null


func update_hover(new_state):
	if new_state:
		if not is_hovering:
			is_hovering = true
		crosshair.hover()
	else:
		if is_hovering:
			is_hovering = false
			crosshair.unhover()


func _physics_process(delta):
	var cur_collider = get_collider()
	# Detect wether hovering grabable item or placeable socket
	if not object_grabbed:
		if cur_collider is RigidBody and cur_collider.mass <= mass_limit:
			update_hover(true)
		else:
			update_hover(false)
	else:
		if object_grabbed is CableJack and cur_collider is SwitchboardSocket:
			update_hover(true)
		else:
			update_hover(false)
		
		# If an object is grabbed then move it infront of me each step
		var vector = $GrabPosition.global_transform.origin - object_grabbed.global_transform.origin
		object_grabbed.linear_velocity = vector * 10
		
		if vector.length() >= 3:
			release()
		
		# IF STATIC BODY WHEN GRABBED USE THIS CODE TO MOVE/ROTATE
		#object_grabbed.global_transform.origin = $GrabPosition.global_transform.origin
		#object_grabbed.rotation.y = $GrabPosition.global_transform.basis.get_euler().y
		#if object_grabbed.name == "End":
		#	object_grabbed.rotation.y += PI / 2
		#else:
		#	object_grabbed.rotation.y += -PI / 2


func _process(_delta):
	var cur_collider = get_collider()
	if Input.is_action_just_pressed("interact"):
		if not object_grabbed:
			if cur_collider is RigidBody and cur_collider.mass <= mass_limit:
				grab(cur_collider)
		else:
			if object_grabbed is CableJack and cur_collider is Area:
				place(cur_collider)
			else:
				release()
	elif Input.is_action_just_pressed("throw"):
		if object_grabbed:
			release(false, true)


func grab(object):
	if object is CableJack:
		if !object.can_be_grabbed:
			print("Object can't be grabbed")
			return false
		
		if object.anchor:
			object.unplug()
	
	is_hovering = false
	crosshair.unhover()
	
	object_grabbed = object
	
	object_grabbed.set_mode(RigidBody.MODE_RIGID)
	object_grabbed.axis_lock_angular_x = false
	object_grabbed.axis_lock_angular_y = false
	object_grabbed.axis_lock_angular_z = false
	return_collision_layer_bit = object_grabbed.get_collision_layer()
	object_grabbed.set_collision_layer(0)
	
	return true


func release(freeze = false, throw = false):
	if !freeze:
		object_grabbed.set_mode(RigidBody.MODE_RIGID)
	if throw:
		object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
	
	object_grabbed.set_collision_layer(return_collision_layer_bit)
	return_collision_layer_bit = null
	object_grabbed = null


func place(target_socket):
	var move_tween = Tween.new()
	var object = object_grabbed
	var target_pos = target_socket.global_transform.origin
	var rot_target = PI / 2 if object_grabbed.name == "End" else -PI / 2
	
	object_grabbed.axis_lock_angular_x = true
	object_grabbed.axis_lock_angular_y = true
	object_grabbed.axis_lock_angular_z = true
	object_grabbed.set_mode(RigidBody.MODE_STATIC)
	object_grabbed.can_be_grabbed = false
	
	move_tween.interpolate_property(object_grabbed, "global_transform:origin", null, target_pos + Vector3(0, 0, 0.1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	move_tween.interpolate_property(object_grabbed, "global_transform:origin", target_pos + Vector3(0, 0, 0.1), target_pos + Vector3(0, 0, 0.05), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.45)
	move_tween.interpolate_property(object_grabbed, "rotation", null, Vector3(0, rot_target, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	add_child(move_tween)
	move_tween.start()
	
	release(true)
	
	yield(move_tween, "tween_all_completed")
	remove_child(move_tween)
	
	object.plug_in(target_socket)
	target_socket.plug_in(object.cable_id)
