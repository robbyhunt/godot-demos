class_name RayCast3D
extends RayCast


var selected_object = null


func _input(_event):
	if not _is_interaction_enabled():
		return
	
	# Force detecting items, in case some of them were deactivated
	_detect_interactive_objects()
	
	if Input.is_action_just_pressed("player_action"):
		_activate_object()
	elif Input.is_action_just_pressed("player_alt_action"):
		_alt_activate_object()


func _process(_delta):
	if _is_interaction_enabled():
		_detect_interactive_objects()


func _detect_interactive_objects():
	var collided = false
	
	if is_colliding():
		var collider = get_collider()
		if collider is StaticBody:
			collider = get_collider().get_parent()
		elif collider is Area:
			collider = get_collider().get_parent().get_parent()
		
		if collider:
			collided = true
			if collider != selected_object:
				_select_object(collider)
	
	if not collided and selected_object:
		_deselect_object()


func _select_object(collider):
	var object_name = collider.name
	var point = get_collision_point()
	selected_object = collider
	print('highlighted object: ', object_name)
	
	if selected_object.has_method('select') and selected_object.select():
		print('selected')


func _deselect_object():
	if selected_object.has_method('de_select') and selected_object.de_select():
		print('de_selected')
	
	selected_object = null


func _activate_object():
	if selected_object:
		if selected_object.has_method('interact') and selected_object.interact():
			print('activated object')
			#goat_interaction.activate_object()
		else:
			print('failed to activate object')


func _alt_activate_object():
	if selected_object:
		if selected_object.has_method('alt_interact') and selected_object.alt_interact():
			print('alt activated object')
			#goat_interaction.alternatively_activate_object()
		else:
			print('failed to alt activate object')


func _is_interaction_enabled():
	#return enabled and not goat_voice.is_playing()
	return enabled
