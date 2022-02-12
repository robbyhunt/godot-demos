extends Position3D

export(bool) var has_interact_spot = false
export(int) var interact_camera_mount

onready var interact_spot = get_node("InteractArea/InteractSpot")
onready var interact_spot_global_pos = interact_spot.to_global(interact_spot.translation)

var look_at_loc


func _process(delta):
	look_at_loc = InteractionManager.camera_controller.get_node("Tripod/Camera").global_transform.origin
	look_at_loc.y = self.global_transform.origin.y
	$Model.look_at(look_at_loc, Vector3.UP)


func interact():
	$AnimationPlayer.play("move", -1, 1.5)
	yield(get_tree().create_timer(1.0), "timeout")
	$AnimationPlayer.play("idle", .2, 1)


func _on_InteractArea_mouse_entered():
	$Model/Sprite.flip_h = true
	InteractionManager.hover(self)


func _on_InteractArea_mouse_exited():
	$Model/Sprite.flip_h = false
	InteractionManager.unhover()
