extends Camera


func _input(_event):
	if Input.is_action_pressed("ui_left"):
		set_rotation(get_rotation() + Vector3(0, 0.1, 0))
	elif Input.is_action_pressed("ui_right"):
		set_rotation(get_rotation() - Vector3(0, 0.1, 0))
	elif Input.is_action_pressed("ui_up"):
		set_rotation(get_rotation() + Vector3(0.1, 0, 0))
	elif Input.is_action_pressed("ui_down"):
		set_rotation(get_rotation() - Vector3(0.1, 0, 0))
