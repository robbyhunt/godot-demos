extends Spatial

onready var camera = get_node("Tripod/Camera")
onready var camera_mounts = get_node("CameraMounts").get_children()
onready var camera_triggers = get_node("CameraTriggers").get_children()
onready var tripod = get_node("Tripod")
onready var tripod_tween = get_node("Tripod/Tween")

var cur_mount_id = 0
var target_mount_transform: Transform
var is_moving = false

signal destination_reached


func _ready():
	for trigger in camera_triggers:
		trigger.get_node("Listener").connect("area_entered", self, "_on_trigger_entered", [trigger])
		trigger.get_node("Listener").connect("area_exited", self, "_on_trigger_exited", [trigger])
	
	tripod_tween.connect("tween_completed", self, "_on_camera_arrived")
	
	tripod.transform = camera_mounts[0].transform
	
	InteractionManager.camera_controller = self
	connect("destination_reached", InteractionManager, "_on_camera_destination_reached")


func _on_trigger_entered(area, trigger):
	if area.name == "PlayerArea":
		if cur_mount_id == trigger.mount_id1:
			switch_mount(trigger.mount_id2)
		elif cur_mount_id == trigger.mount_id2:
			switch_mount(trigger.mount_id1)


func _on_trigger_exited(area, trigger):
	if area.name == "PlayerArea":
		if trigger.exit1_active and cur_mount_id != trigger.mount_id1:
			switch_mount(trigger.mount_id1)
		elif trigger.exit2_active and cur_mount_id != trigger.mount_id2:
			switch_mount(trigger.mount_id2)


func switch_mount(mount_id):
	target_mount_transform = camera_mounts[mount_id].transform
	cur_mount_id = mount_id
	move_camera()


func move_camera():
	is_moving = true
	tripod_tween.interpolate_property(tripod, "transform", tripod.transform, target_mount_transform, 2, 1, 2)
	tripod_tween.start()


func _on_camera_arrived(_object, _property):
	is_moving = false
	emit_signal("destination_reached")
