extends Position3D

enum INTERACTION_TYPES { DIALOGUE }

export(INTERACTION_TYPES) var interaction_type = INTERACTION_TYPES.DIALOGUE

export(String) var voice = "lowest"
export(float) var voice_pitch = 6.0

export(bool) var has_interact_spot = false
export(int) var interact_camera_mount

onready var game_camera = get_owner().get_node("CameraController").get_node("Tripod/Camera")
onready var interact_spot = get_node("InteractArea/InteractSpot")
onready var interact_spot_global_pos = interact_spot.to_global(interact_spot.translation)

const conversation = [
	[1, "My hotels as clean as an elven arse!"],
	[0, "That doesn't sound very appealing."]
   ]

var look_at_loc


func _process(_delta):
	look_at_loc = game_camera.global_transform.origin
	look_at_loc.y = self.global_transform.origin.y
	$Model.look_at(look_at_loc, Vector3.UP)


func _on_InteractArea_mouse_entered():
	$Model/Sprite.flip_h = true
	InteractionManager.hover(self)


func _on_InteractArea_mouse_exited():
	$Model/Sprite.flip_h = false
	InteractionManager.unhover()
