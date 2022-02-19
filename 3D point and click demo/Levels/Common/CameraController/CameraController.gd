extends Spatial

onready var camera = get_node("Tripod/Camera")
onready var camera_mounts = get_node("CameraMounts").get_children()
onready var camera_triggers = get_node("CameraTriggers").get_children()
onready var tripod = get_node("Tripod")
onready var tripod_tween = get_node("Tripod/Tween")

var cur_mount_id: int = 0
var return_mount_id
var target_mount_transform: Transform


func _ready():
	# warning-ignore:return_value_discarded
	GameEvents.connect("interaction_init", self, "_on_interaction_init")
	# warning-ignore:return_value_discarded
	GameEvents.connect("interaction_cancelled", self, "_on_interaction_ended")
	# warning-ignore:return_value_discarded
	GameEvents.connect("interaction_ended", self, "_on_interaction_ended")
	
	tripod.transform = camera_mounts[0].transform
	tripod_tween.connect("tween_completed", self, "_on_camera_destination_reached")
	for trigger in camera_triggers:
		trigger.get_node("Listener").connect("area_entered", self, "_on_trigger_entered", [trigger])
		trigger.get_node("Listener").connect("area_exited", self, "_on_trigger_exited", [trigger])


func switch_mount(mount_id):
	target_mount_transform = camera_mounts[mount_id].transform
	cur_mount_id = mount_id
	move_camera()


func move_camera():
	tripod_tween.interpolate_property(tripod, "transform", tripod.transform, target_mount_transform, 2, 1, 2)
	tripod_tween.start()


func _on_trigger_entered(_area, trigger):
	if cur_mount_id == trigger.mount_id1:
		switch_mount(trigger.mount_id2)
	elif cur_mount_id == trigger.mount_id2:
		switch_mount(trigger.mount_id1)


func _on_trigger_exited(_area, trigger):
	if trigger.exit1_active and cur_mount_id != trigger.mount_id1:
		switch_mount(trigger.mount_id1)
	elif trigger.exit2_active and cur_mount_id != trigger.mount_id2:
		switch_mount(trigger.mount_id2)


func _on_camera_destination_reached(_object, _property):
	GameEvents.emit_signal("camera_destination_reached", cur_mount_id)


func _on_interaction_init(mount_id):
	return_mount_id = cur_mount_id
	switch_mount(mount_id)


func _on_interaction_ended():
	if return_mount_id != null:
		switch_mount(return_mount_id)
		return_mount_id = null
