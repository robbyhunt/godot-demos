extends Position3D

export(bool) var has_interact_spot = false

onready var interact_spot = get_node("InteractArea/InteractSpot")
onready var interact_spot_global_pos = interact_spot.to_global(interact_spot.translation)


func interact():
	$AnimationPlayer.play("move", -1, 1.5)
	yield(get_tree().create_timer(1.0), "timeout")
	$AnimationPlayer.play("idle", .2, 1)


func _on_InteractArea_mouse_entered():
	$Sprite.flip_h = true
	InteractionManager.hover_object(self)


func _on_InteractArea_mouse_exited():
	$Sprite.flip_h = false
	InteractionManager.unhover()
