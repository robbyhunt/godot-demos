extends InteractArea

export(bool) var is_open = false
export(bool) var is_locked = false

onready var anim_player = get_node("AnimationPlayer")

var is_animating = false


func interact():
	if is_animating:
		return false
	
	if is_locked:
		anim_player.play("locked")
	else:
		if is_open:
			anim_player.play("close", 1)
		else:
			anim_player.play("open", 1)
		is_animating = true
		is_open = !is_open
	
	return true


func _on_AnimationPlayer_animation_finished(_anim_name):
	is_animating = false


func _on_Door_mouse_entered():
	_on_Area_mouse_entered()


func _on_Door_mouse_exited():
	_on_Area_mouse_exited()
