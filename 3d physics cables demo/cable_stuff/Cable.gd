extends Spatial
class_name Cable

enum LENGTHS {SMALL, MEDIUM, LONG}

export(int) var cable_id = 0
export(LENGTHS) var cable_length = LENGTHS.MEDIUM

onready var start_node = get_node("Start")
onready var end_node = get_node("End")

var max_length
var cur_distance_between


func _ready():
	match cable_length:
		LENGTHS.SMALL:
			max_length = 0.6
		LENGTHS.MEDIUM:
			max_length = 1
		LENGTHS.LONG:
			max_length = 1.5
	
	start_node.is_start = true
	end_node.is_start = false
	start_node.cable_id = cable_id
	end_node.cable_id = cable_id


func _process(_delta):
	if start_node.anchor or end_node.anchor:
		var anchored_node = end_node if end_node.anchor else start_node
		cur_distance_between = start_node.global_transform.origin.distance_to(end_node.global_transform.origin)
		
		if cur_distance_between > max_length:
			anchored_node.unplug()
			print("range exceeded")
