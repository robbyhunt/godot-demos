extends Spatial

signal destination_reached()

export (NodePath) var ControllerTarget
export (int, 2, 6) var move_speed = 3
export (int) var acceleration = 6

onready var controller_target = get_node(ControllerTarget)

var destination
var stop_range
var distance_to_destination
var path = []
var cur_speed = 0

func _physics_process(delta):
	if path.size() > 0:
		var direction = Vector3()
		var step_amount = delta * cur_speed
		var step_destination = path[0]
		
		accelerate(delta)
		
		direction = step_destination - controller_target.get_global_pos()
		
		distance_to_destination = destination.distance_to(controller_target.get_global_pos())
		
		if distance_to_destination <= stop_range:
			arrive()
			return
		
		if step_amount > direction.length():
			step_amount = direction.length()
			
			path.remove(0)
			if path.size() <= 0:
				arrive()
				return
		
		controller_target.translation += direction.normalized() * step_amount


func arrive():
	path = []
	destination = null
	stop_range = null
	distance_to_destination = null
	cur_speed = 0
	emit_signal("destination_reached")


func accelerate(delta):
	## COMMENTED OUT BROKEN DECELERATION
	#var dir = destination - controller_target.translation
	#var cur_distance_to_destination = dir.length()
	
	#if cur_distance_to_destination < (init_distance_to_destination / 4):
	#	cur_speed = clamp(cur_speed - 2 * delta, 0.25, move_speed)
	#el...
	if cur_speed < move_speed:
		cur_speed += acceleration * delta


func set_destination(dest, _stop_range):
	path = []
	destination = dest
	stop_range = _stop_range
	distance_to_destination = destination.distance_to(controller_target.get_global_pos())
	path = get_parent().get_owner().get_simple_path(controller_target.get_global_pos(), destination, true)
	
	if path.size() > 0 and distance_to_destination > stop_range:
		return true
	else:
		return false
