extends MeshInstance

var active_connections = {}

var sockets


func _ready():
	sockets = get_node("Sockets").get_children()
	var id = 0
	for socket in sockets:
		socket.init(id)
		socket.connect("plugged_in", self, "plug_in")
		socket.connect("unplugged", self, "unplug")
		id += 1


func plug_in(socket_id, cable_id):
	if !active_connections.has(cable_id):
		# Plugged in one end of cable
		active_connections[cable_id] = [socket_id, null]
		update_socket_state(socket_id, 1)
		
		update_dev_label()
		
	elif active_connections[cable_id][0] == null:
		# Both ends plggued in (id 0 was empty)
		active_connections[cable_id][0] = socket_id
		update_both_socket_states(cable_id, 2)
	elif active_connections[cable_id][1] == null:
		# Both ends plggued in (id 1 was empty)
		active_connections[cable_id][1] = socket_id
		update_both_socket_states(cable_id, 2)
	else:
		return false
	
	return true


func unplug(socket_id, cable_id):
	# Need to check if socket is first or second entry in the active connection (lame)
	if active_connections[cable_id][0] == socket_id:
		# Disconnect socket unplugged
		update_socket_state(socket_id, 0)
		
		# If there was an active connection, set other socket pending
		if !active_connections[cable_id][1] == null:
			update_socket_state(active_connections[cable_id][1], 1)
		
		# Clear the value of unplugged socket
		active_connections[cable_id][0] = null
	
	elif active_connections[cable_id][1] == socket_id:
		# Disconnect socket unplugged
		update_socket_state(socket_id, 0)
		
		# If there was an active connection, set other socket pending
		if !active_connections[cable_id][0] == null:
			update_socket_state(active_connections[cable_id][0], 1)
		
		# Disconnect socket unplugged
		active_connections[cable_id][1] = null
	
	# If neither end of the cable remains plugged in, remove the key from active connections
	if active_connections[cable_id][0] == null and active_connections[cable_id][1] == null:
		active_connections.erase(cable_id)
	
	update_dev_label()


func update_both_socket_states(cable_id, state_id):
	var index = 1
	for socket_id in active_connections[cable_id]:
		var partner_socket_id = active_connections[cable_id][index]
		sockets[socket_id].set_connection_state(state_id, partner_socket_id)
		index -= 1
		
	update_dev_label()


func update_socket_state(socket_id, state_id):
	sockets[socket_id].set_connection_state(state_id)


func update_dev_label():
	$Control/Label.text = ""
	$Control/Label2.text = ""
	$Control/Label3.text = ""
	
	for key in active_connections:
		$Control/Label.text +=  "Connection " + str(key) + ": " + str(active_connections[key][0]) + " " + str(active_connections[key][1])
		if (key != active_connections.keys().back()):
			$Control/Label.text += "\n"
	
	var socket_id = 0
	for socket in sockets:
		var label_to_use
		if socket_id < 25:
			label_to_use = $Control/Label3
		else:
			label_to_use = $Control/Label2
		label_to_use.text +=  str(socket.name) + " state: " + str(socket.connection_state) + "(" + str(socket.partner_socket_index) + ")\n"
		socket_id += 1
