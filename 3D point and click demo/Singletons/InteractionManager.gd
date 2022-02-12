extends Node

var is_mouse_hovering = false
var object_hovered
var object_queued
var object_interacting

var waiting_for_camera = false

var camera_controller

var return_camera_mount


func hover(object):
	if is_mouse_hovering and object_hovered.has_method("unhover"):
		object_hovered.unhover()
	else:
		is_mouse_hovering = true
	object_hovered = object


func unhover():
	is_mouse_hovering = false
	object_hovered = null


func queue_object():
	object_queued = object_hovered


func interact():
	if object_queued:
		if object_queued.interact_camera_mount:
			return_camera_mount = camera_controller.cur_mount_id
			camera_controller.switch_mount(object_queued.interact_camera_mount)
		else:
			object_queued.interact()
			object_interacting = object_queued
			object_queued = null


func end_interaction():
	object_interacting = null
	if return_camera_mount:
		camera_controller.switch_mount(return_camera_mount)


func _on_camera_destination_reached():
	if object_queued:
		if camera_controller.cur_mount_id == object_queued.interact_camera_mount:
			object_queued.interact()
			object_interacting = object_queued
			object_queued = null
