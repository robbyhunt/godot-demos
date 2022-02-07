extends StaticBody

class_name Campfire

export(bool) var is_burning = true

onready var flames = get_node("Flame")
onready var smoke = get_node("Smoke")
onready var light = get_node("OmniLight")

func _ready():
	var world_node = get_node("../../..")
	var g_pos = world_node.world_to_map(global_transform.origin)
	global_transform.origin = world_node.map_to_world(g_pos.x, g_pos.y, g_pos.z)
	# FILL THE CELL ON THE WORLD GRID - DISABLED FOR NOW BECAUSE GRID DOESN'T WARP TO CYLINDER. NEED TO WRITE CUSTOM GRID TRACKING STUFF
	#world_node.set_cell_item(g_pos.x, g_pos.y, g_pos.z, 0)
	
	if is_burning:
		flames.set_emitting(true)
		smoke.set_emitting(true)
		light.show()
	else:
		flames.set_emitting(false)
		smoke.set_emitting(false)
		light.hide()


func toggle_fire():
	is_burning = !is_burning
	flames.set_emitting(is_burning)
	smoke.set_emitting(is_burning)
	light.visible = is_burning


func show_interactable():
	$InteractIcon.show()


func hide_interactable():
	$InteractIcon.hide()
