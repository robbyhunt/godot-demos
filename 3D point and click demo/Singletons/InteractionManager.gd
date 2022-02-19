extends Node

enum INTERACTION_TYPES { DIALOGUE, LOCAL_INTERACT }

var object_hovered
var object_queued
var object_interacting
var waiting_for_camera = false


var player_ref


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
		if object_queued.has_interact_camera_mount:
			GameEvents.emit_signal("interaction_init", object_queued.interact_camera_mount)
		else:
			start_interaction()


func start_interaction():
	match object_queued.interaction_type:
		INTERACTION_TYPES.DIALOGUE:
			DialogueManager.start_dialogue(object_queued)
			object_interacting = object_queued
		INTERACTION_TYPES.LOCAL_INTERACT:
			object_queued.interact()
	object_queued = null


func end_interaction():
	match object_interacting.interaction_type:
		INTERACTION_TYPES.DIALOGUE:
			DialogueManager.end_dialogue()
		INTERACTION_TYPES.LOCAL_INTERACT:
			pass
	object_interacting = null
	GameEvents.emit_signal("interaction_ended")


func _on_camera_destination_reached(camera_mount_id):
	if object_queued:
		if object_queued.has_interact_camera_mount:
			if camera_mount_id == object_queued.interact_camera_mount:
				start_interaction()
