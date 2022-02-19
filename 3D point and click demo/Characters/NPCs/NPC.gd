extends InteractArea

export(String) var voice = "lowest"
export(float) var voice_pitch = 6.0

onready var game_camera = get_owner().get_node("CameraController").get_node("Tripod/Camera")


const conversation = [
	[1, "My hotels as clean as an elven arse!"],
	[0, "That doesn't sound very appealing."]
   ]

var look_at_loc


func get_global_pos():
	return get_parent().to_global(self.translation)


func _process(_delta):
	look_at_loc = game_camera.global_transform.origin
	look_at_loc.y = self.global_transform.origin.y
	$Model.look_at(look_at_loc, Vector3.UP)
