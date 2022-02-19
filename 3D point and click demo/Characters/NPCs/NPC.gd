extends InteractArea

export(String) var voice = "lowest"
export(float) var voice_pitch = 6.0

onready var game_camera = get_owner().get_node("CameraController").get_node("Tripod/Camera")


const conversation = [
	[1, "My hotels as clean as an elven arse!"],
	[0, "That doesn't sound very appealing."]
   ]

const conversation2 = [
	[1, "My hotels as clean as an elven arse!"],
	[0, "That doesn't sound very appealing."]
   ]

const conversation3 = [
	[1, "Don't say anything back to me."]
   ]

var look_at_loc


func _process(_delta):
	look_at_loc = game_camera.global_transform.origin
	look_at_loc.y = self.global_transform.origin.y
	$Model.look_at(look_at_loc, Vector3.UP)
