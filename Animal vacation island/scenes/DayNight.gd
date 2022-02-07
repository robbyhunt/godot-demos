extends AnimationPlayer

var last_played = "Day"

func _input(event):
	if Input.is_action_just_pressed("dev"):
		if last_played == "Day":
			play("Night")
			last_played = "Night"
		else:
			play("Day")
			last_played = "Day"
