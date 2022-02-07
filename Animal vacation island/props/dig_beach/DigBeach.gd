extends StaticBody

class_name DigSpot

signal dig_end

export(int) var drop_chance = 80

onready var item_base = preload("res://entities/items/ItemBase.tscn")
onready var mound_mesh = get_node("MeshInstance")
onready var hole_mesh = get_node("MeshInstance2")


func show_interactable():
	$InteractIcon.show()


func hide_interactable():
	$InteractIcon.hide()


func dig():
	yield(get_tree().create_timer(1), "timeout")
	var spawn_roll = randi() % 100
	if spawn_roll >= 100 - drop_chance:
		var new_item = item_base.instance()
		new_item.translation = translation + Vector3(1, 2, 0)
		get_parent().add_child(new_item)
	mound_mesh.hide()
	hole_mesh.show()
	# COMMENTED OUT SO YOU CAN WALK OVER HOLES FOR NOW
	#set_collision_layer_bit(0, true)
	set_collision_layer_bit(3, false)
	emit_signal("dig_end", self, "dig_end")
