extends Spatial

export(int) var mount_id1
export(int) var mount_id2

var exit1_active = false
var exit2_active = false


func _on_Exit_area_event(_area, exit_id, entering):
	match exit_id:
		1:
			exit1_active = entering
		2:
			exit2_active = entering
