extends Area
class_name InteractArea


export(InteractionManager.INTERACTION_TYPES) var interaction_type = InteractionManager.INTERACTION_TYPES.LOCAL_INTERACT
export(float, 10.0) var interact_range = 0
export(bool) var has_interact_spot_override = false
export(bool) var has_interact_camera_mount = false
export(bool) var has_dialogue_spot = false
export(int) var interact_camera_mount


onready var interact_spot_global_pos = self.global_transform.origin
onready var dialogue_pos = self


func _ready():
	if has_interact_spot_override:
		interact_spot_global_pos = get_node("InteractSpot").global_transform.origin
	if has_dialogue_spot:
		dialogue_pos = get_node("DialogueSpot")


func _on_Area_mouse_entered():
	Input.set_default_cursor_shape(2)
	InteractionManager.hover(self)


func _on_Area_mouse_exited():
	Input.set_default_cursor_shape(0)
	InteractionManager.unhover()
