extends StaticBody

class_name TreeProp

signal shake_end

export(bool) var is_fruit_tree = false
export(int) var max_shake_attempts = 3
export(int) var drop_chance = 20

onready var item_base = preload("res://entities/items/ItemBase.tscn")
onready var mesh_instance = get_node("Tree")
onready var mesh_roll = randi() % 5 + 1

var times_shaken = 0
var fruit_instances = []


func _ready():
	mesh_instance.mesh = load("res://props/tree/assets/meshes/Tree" + str(mesh_roll) + ".mesh")
	var world_node = get_node("../../..")
	var g_pos = world_node.world_to_map(global_transform.origin)
	global_transform.origin = world_node.map_to_world(g_pos.x, g_pos.y, g_pos.z)
	# FILL THE CELL ON THE WORLD GRID - DISABLED FOR NOW BECAUSE GRID DOESN'T WARP TO CYLINDER. NEED TO WRITE CUSTOM GRID TRACKING STUFF
	#world_node.set_cell_item(g_pos.x, g_pos.y, g_pos.z, 0)
	
	#if mesh_roll == 5:
	#	is_fruit_tree = true
	
	if is_fruit_tree:
		var fruit_index = 0
		while fruit_index < 3:
			var new_item = item_base.instance()
			var item_spawn_offset = Vector3(0, 4, 0)
			match fruit_index:
				0:
					item_spawn_offset = Vector3(2, 4.75, 1)
				1:
					item_spawn_offset = Vector3(-1.5, 4.5, 0)
				2:
					item_spawn_offset = Vector3(0, 4, 2)
			new_item.sleeping = true
			new_item.global_transform.origin = global_transform.origin + item_spawn_offset
			new_item.set_meta("id", "apple")
			new_item.set_meta("quantity", 1)
			var new_item_mesh_instance = new_item.get_node("MeshInstance")
			for surface_count in new_item_mesh_instance.get_surface_material_count():
				new_item_mesh_instance.get_surface_material(surface_count).set_shader_param("active", true)
				new_item_mesh_instance.get_surface_material(surface_count).set_shader_param("radius", GameData.globe_shader_radius)
				
			fruit_instances.append(new_item)
			get_node("../..").call_deferred("add_child", new_item)
			fruit_index += 1


func shake():
	$AnimationPlayer.play("shake")
	if is_fruit_tree and len(fruit_instances) > 0:
		var shake_roll = randi() % len(fruit_instances) + 1
		var index = 0
		for fruit in fruit_instances:
			if index < shake_roll:
				if fruit.sleeping:
					fruit.sleeping = false
					fruit_instances.remove(index)
					index += 1
	elif times_shaken < max_shake_attempts:
		var spawn_roll = randi() % 100
		if spawn_roll >= 100 - drop_chance:
			var new_item = item_base.instance()
			var randi_id = randi() % 3 - 1
			var item_spawn_offset = Vector3(0, 4, 0)
			match randi_id:
				-1:
					item_spawn_offset.x = -1
				0:
					item_spawn_offset.z = 1
				1:
					item_spawn_offset.x = 1
			new_item.translation = translation + item_spawn_offset
			new_item.set_meta("id", "apple")
			new_item.set_meta("quantity", 1)
			get_node("../..").add_child(new_item)
	times_shaken += 1


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shake":
		emit_signal("shake_end", self, "shake_end")


func show_interactable():
	$InteractIcon.show()


func hide_interactable():
	$InteractIcon.hide()
