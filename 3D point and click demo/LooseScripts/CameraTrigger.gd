extends Spatial

export(int) var mount_id1
export(int) var mount_id2

var exit1_active = false
var exit2_active = false


func _on_Exit_area_event(area, exit_id, entering):
	if area.name == "PlayerArea":
		match exit_id:
			1:
				exit1_active = entering
			2:
				exit2_active = entering
