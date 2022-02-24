extends Area
class_name SwitchboardSocket

signal plugged_in(socket_id, cable_id)
signal unplugged(socket_id, cable_id)

enum CONNECTION_STATES { NO_CONNECTION, PENDING, CONNECTED }

onready var light_off_material = preload("res://switchboard/light_off.material")
onready var light_pending_material = preload("res://switchboard/light_pending.material")
onready var light_on_material = preload("res://switchboard/light_on.material")

var socket_index: int = 0
var connection_state = CONNECTION_STATES.NO_CONNECTION
var partner_socket_index


func init(id):
	socket_index = id


func plug_in(cable_id):
	#$LightMesh.set_surface_material(0, light_on_material)
	emit_signal("plugged_in", socket_index, cable_id)


func unplug(cable_id):
	emit_signal("unplugged", socket_index, cable_id)


func set_connection_state(state_id, partner_socket_id = null):
	var material
	var new_state
	var is_detectable = false
	
	match state_id:
		0:
			new_state = CONNECTION_STATES.NO_CONNECTION
			material = light_off_material
			is_detectable = true
		1:
			new_state = CONNECTION_STATES.PENDING
			material = light_pending_material
		2:
			new_state = CONNECTION_STATES.CONNECTED
			material = light_on_material
	
	connection_state = new_state
	partner_socket_index = partner_socket_id
	$LightMesh.set_surface_material(0, material)
	$CollisionShape.disabled = !is_detectable
