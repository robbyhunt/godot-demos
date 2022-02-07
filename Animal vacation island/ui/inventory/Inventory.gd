extends Control

var gamepad_timeout = false

onready var item_base = preload("ItemBase.tscn")
onready var row_length = len($Window/Panel/VBoxContainer.get_child(0).get_children())
var inv = {}

var item_grabbed = null
var grabbed_return_index = null

func _ready():
	# warning-ignore:return_value_discarded
	$Cursor.connect("cursor_select", self, "_on_item_selected")
	# warning-ignore:return_value_discarded
	GameEvents.connect("item_pickup", self, "_on_item_pickup")
	
	var inv_build_index = 0
	for row in $Window/Panel/VBoxContainer.get_children():
		for slot in row.get_children():
			inv[inv_build_index] = {}
			inv_build_index += 1
	
	for index in GameData.player_inv:
		if GameData.player_inv[index]:
			inv[index] = GameData.player_inv[index]
			update_ui(index)


func _process(_delta):
	if item_grabbed:
		item_grabbed.rect_position = $Cursor.rect_position + Vector2(-32, 0)


func _on_item_selected(cursor_index, menu_index):
	gamepad_timeout = true
	var slot_index = cursor_index
	match menu_index:
		1:
			slot_index += row_length
		2:
			slot_index += row_length * 2
	select_item(slot_index)
	yield(get_tree().create_timer(.01), "timeout")
	gamepad_timeout = false
	


func select_item(slot_index): 
	if item_grabbed:
		if inv[slot_index] and item_grabbed.get_meta("id") != inv[slot_index]["id"]:
			swap(slot_index)
		else:
			add_item_at_index(slot_index, item_grabbed.get_meta("id"), item_grabbed.get_meta("quantity"))
	elif inv[slot_index]:
		grab(slot_index)


func swap(slot_index):
	var cur_in_slot = get_node_from_index(slot_index).get_child(0)
	var cur_in_slot_new_instance = cur_in_slot.duplicate()
	inv[slot_index]["id"] = item_grabbed.get_meta("id")
	inv[slot_index]["quantity"] = item_grabbed.get_meta("quantity")
	item_grabbed.queue_free()
	cur_in_slot.queue_free()
	add_child(cur_in_slot_new_instance)
	item_grabbed = cur_in_slot_new_instance
	update_ui(slot_index)


func grab(slot_index):
	item_grabbed = get_node_from_index(slot_index).get_child(0).duplicate()
	grabbed_return_index = slot_index
	add_child(item_grabbed)
	inv[slot_index] = {}
	GameData.player_inv[slot_index] = null
	update_ui(slot_index)


func _on_item_pickup(item_instance):
	var item_id = item_instance.get_meta("id")
	var item_quantity = item_instance.get_meta("quantity")
	if item_id == null:
		item_id = "error"
	if item_quantity == null:
		item_quantity = 1
	
	for slot in inv:
		if !inv[slot]:
			add_item_at_index(slot, item_id, item_quantity)
			item_instance.queue_free()
			break
		elif inv[slot]["id"] == item_id:
			if GameData.item_db[item_id]["stackable"]:
				if add_item_at_index(slot, item_id, item_quantity):
					item_instance.queue_free()
					break


func add_item_at_index(slot_index, item_id, quantity):
	if inv[slot_index]:
		if inv[slot_index]["id"] == item_id and GameData.item_db[item_id]["stackable"]:
			if stack(slot_index, item_id, quantity):
				return true
		else:
			return false
	else:
		inv[slot_index]["id"] = item_id
		inv[slot_index]["quantity"] = quantity
		GameData.player_inv[slot_index] = inv[slot_index]
		if item_grabbed:
			clear_grab()
		update_ui(slot_index)
		return true


func stack(slot_index, item_id, quantity):
	var clear_grabbed = true
	var new_quantity = inv[slot_index]["quantity"] + quantity
	var max_stack = GameData.item_db[item_id]["max_stack"]
	if new_quantity > max_stack:
		var overflow_quantity = new_quantity - max_stack
		clear_grabbed = false
		new_quantity = max_stack
		if item_grabbed:
			item_grabbed.set_meta("quantity", overflow_quantity)
			item_grabbed.get_child(0).text = str(overflow_quantity)
		else:
			return false
	inv[slot_index]["quantity"] = new_quantity
	GameData.player_inv[slot_index] = inv[slot_index]
	update_ui(slot_index, true)
	if item_grabbed and clear_grabbed:
		clear_grab()
	return true


func clear_grab():
	item_grabbed.queue_free()
	item_grabbed = null
	grabbed_return_index = null


func update_ui(slot_to_update, is_stack_update = false):
	var slot_node = get_node_from_index(slot_to_update)
	
	if inv[slot_to_update]:
		if is_stack_update:
			slot_node.get_child(0).set_meta("quantity", inv[slot_to_update]["quantity"])
			if inv[slot_to_update]["quantity"] > 1:
				slot_node.get_child(0).get_child(0).text = str(inv[slot_to_update]["quantity"])
				slot_node.get_child(0).get_child(0).show()
		else:
			var new_tex = item_base.instance()
			new_tex.set_texture(load(GameData.item_db[inv[slot_to_update]["id"]]["asset"]))
			new_tex.set_meta("id", inv[slot_to_update]["id"])
			new_tex.set_meta("quantity", inv[slot_to_update]["quantity"])
			if inv[slot_to_update]["quantity"] > 1:
				new_tex.get_child(0).text = str(inv[slot_to_update]["quantity"])
				new_tex.get_child(0).show()
			slot_node.add_child(new_tex)
	else:
		slot_node.get_child(0).queue_free()


func get_node_from_index(slot_index):
	var slot_node
	if slot_index <= row_length - 1:
		slot_node = get_node("Window/Panel/VBoxContainer/HBoxContainer/Panel" + str(slot_index))
	elif slot_index <= row_length * 2 - 1:
		slot_node = get_node("Window/Panel/VBoxContainer/HBoxContainer2/Panel" + str(slot_index - row_length))
	elif slot_index <= row_length * 3 - 1:
		slot_node = get_node("Window/Panel/VBoxContainer/HBoxContainer3/Panel" + str(slot_index - row_length * 2))
	return slot_node
