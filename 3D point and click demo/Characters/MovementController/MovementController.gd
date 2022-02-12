extends Spatial

signal destination_reached()

export (NodePath) var ControllerTarget
export (int, 2, 6) var move_speed = 3
export (int) var acceleration = 6

onready var controller_target = get_node(ControllerTarget)

var destination
var init_distance_to_destination
var path = []
var cur_speed = 0

func _physics_process(delta):
	if path.size() > 0:
		accelerate(delta)
		
		var direction = Vector3()
		var step_amount = delta * cur_speed
		var step_destination = path[0]
		
		direction = step_destination - controller_target.translation
		
		if step_amount > direction.length():
			step_amount = direction.length()
			
			path.remove(0)
			if path.size() <= 0:
				destination = null
				init_distance_to_destination = null
				cur_speed = 0
				emit_signal("destination_reached")
		
		controller_target.translation += direction.normalized() * step_amount


func accelerate(delta):
	## COMMENTED OUT BROKEN DECELERATION
	#var dir = destination - controller_target.translation
	#var cur_distance_to_destination = dir.length()
	
	#if cur_distance_to_destination < (init_distance_to_destination / 4):
	#	cur_speed = clamp(cur_speed - 2 * delta, 0.25, move_speed)
	#el...
	if cur_speed < move_speed:
		cur_speed += acceleration * delta


func set_destination(dest):
	path = []
	destination = dest
	init_distance_to_destination = (destination - controller_target.translation).length()
	path = get_parent().get_owner().get_simple_path(controller_target.translation, destination, true)
	
	if path.size() > 0 and init_distance_to_destination > 0.1:
		return true
	else:
		return false
