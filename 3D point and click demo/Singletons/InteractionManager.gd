extends Node

enum INTERACTION_TYPES { DIALOGUE }

var object_hovered
var object_queued
var object_interacting
var waiting_for_camera = false


func _ready():
	GameEvents.connect("camera_destination_reached", self, "_on_camera_destination_reached")


func hover(object):
	if object_hovered and object_hovered.has_method("unhover"):
		object_hovered.unhover()
	object_hovered = object


func unhover():
	object_hovered = null


func queue_object():
	object_queued = object_hovered


func clear_queued():
	object_queued = null
	GameEvents.emit_signal("interaction_cancelled")


func interact():
	if object_queued:
		if object_queued.interact_camera_mount:
			GameEvents.emit_signal("interaction_init", object_queued.interact_camera_mount)
		else:
			start_interaction()


func start_interaction():
	match object_queued.interaction_type:
		INTERACTION_TYPES.DIALOGUE:
			GameEvents.emit_signal("dialogue_started", object_queued)
	GameEvents.emit_signal("interaction_started")
	object_interacting = object_queued
	object_queued = null


func end_interaction():
	#match object_interacting.interaction_type:
	#	INTERACTION_TYPES.DIALOGUE:
	#		GameEvents.emit_signal("dialogue_ended")
	object_interacting = null
	GameEvents.emit_signal("interaction_ended")


func _on_camera_destination_reached(camera_mount_id):
	if object_queued:
		if camera_mount_id == object_queued.interact_camera_mount:
			start_interaction()
