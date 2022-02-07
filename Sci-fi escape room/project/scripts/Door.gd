extends MeshInstance

class_name Door

export(bool) var is_locked = false
export(NodePath) var anim_player_path
onready var anim_player: AnimationPlayer = get_node(anim_player_path)


var is_open: bool = false


func interact():
	if anim_player.is_playing():
		return false
	
	if is_locked:
		anim_player.play('locked')
	else:
		if is_open:
			anim_player.play_backwards('open')
		else:
			anim_player.play('open')
		
		is_open = !is_open
	
	return true
