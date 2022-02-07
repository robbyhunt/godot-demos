extends Node

var is_mouse_hovering = false
var object_hovered
var object_queued


func hover_object(object):
	if is_mouse_hovering and object_hovered.has_method("unhover"):
		object_hovered.unhover()
	else:
		is_mouse_hovering = true
	object_hovered = object


func unhover():
	is_mouse_hovering = false
	object_hovered = null


func interact():
	if object_queued:
		object_queued.interact()
		object_queued = null
		return
	
	if object_hovered:
		object_hovered.interact()


func queue_object():
	object_queued = object_hovered
