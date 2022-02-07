extends Camera

onready var anim_player = $AnimationPlayer
onready var anim_length

var prev_anim_seek = null

func _ready():
	# warning-ignore:return_value_discarded
	GameEvents.connect("dialogue_start", self, "_dialogue_zoom_in")
	# warning-ignore:return_value_discarded
	GameEvents.connect("dialogue_end", self, "_dialogue_zoom_out")
	
	anim_player.play("camera_zoom")
	anim_player.stop(false)
	anim_length = anim_player.get_current_animation_length()


func _input(event):
	if GameState.state == GameState.STATES.FREEWALK:
		if event is InputEventMouseButton:
			if event.is_action_pressed("zoom_in"):
				anim_player.seek(anim_player.get_current_animation_position() + 0.025, true)
			elif event.is_action_pressed("zoom_out"):
				anim_player.seek(anim_player.get_current_animation_position() - 0.025, true)
		else:
			if event.is_action_pressed("zoom_in"):
				if anim_player.get_current_animation_position() < anim_length:
					anim_player.play("camera_zoom")
			elif event.is_action_pressed("zoom_out"):
				if anim_player.get_current_animation_position() > 0:
					anim_player.play_backwards("camera_zoom")
			elif Input.is_action_just_released("zoom_in") or Input.is_action_just_released("zoom_out"):
				anim_player.stop(false)


func _dialogue_zoom_in(_arg, _arg2):
	prev_anim_seek = anim_player.get_current_animation_position()
	if prev_anim_seek != anim_length:
		anim_player.play("camera_zoom")


func _dialogue_zoom_out():
	if prev_anim_seek != anim_length:
		anim_player.play_backwards("camera_zoom")
		yield(get_tree().create_timer(anim_length - prev_anim_seek), "timeout")
		anim_player.stop(false)
