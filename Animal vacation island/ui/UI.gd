extends CanvasLayer

var gamepad_timer = false

func _input(_event):
	if Input.is_action_just_pressed("toggle_inv") and !gamepad_timer:
		gamepad_timer = true
		if !$Inventory.visible:
			if GameState.state == GameState.STATES.FREEWALK:
				GameState.change_state(GameState.STATES.TALK)
				GameEvents.emit_signal("state_changed")
				$Inventory.visible = true
		else:
			GameState.change_state(GameState.STATES.FREEWALK)
			$Inventory.visible = false
		yield(get_tree().create_timer(.01), "timeout")
		gamepad_timer = false
