extends RigidBody
class_name CableJack

var anchor = null
var is_start = false
var cable_id = null

var can_be_grabbed = true


func plug_in(socket):
	anchor = socket
	can_be_grabbed = true


func unplug():
	anchor.unplug(cable_id)
	anchor = null
	set_mode(RigidBody.MODE_RIGID)
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false
