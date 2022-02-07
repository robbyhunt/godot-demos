extends TextureRect

export var row_count : int = 1
export var menu_parent_path : NodePath
export var second_menu_parent_path : NodePath
export var third_menu_parent_path : NodePath
export var base_ui_node_path : NodePath
export var cursor_offset : Vector2

onready var menu_parent := get_node(menu_parent_path)
var second_menu_parent
var third_menu_parent
onready var current_menu_parent = menu_parent
onready var base_ui_element = get_node(base_ui_node_path)

var cursor_index : int = 0
var menu_index : int = 0

signal cursor_select(index)


func _ready():
	if row_count > 1:
		second_menu_parent = get_node(second_menu_parent_path)
	if row_count > 2:
		third_menu_parent = get_node(third_menu_parent_path)


func _unhandled_input(_event):
	if base_ui_element.visible and !base_ui_element.gamepad_timeout:
		if Input.is_action_just_pressed("ui_select"):
			var current_menu_item := get_menu_item_at_index(cursor_index)
			
			if current_menu_item != null:
				emit_signal("cursor_select", cursor_index, menu_index)

func _process(_delta):
	if base_ui_element.visible:
		var input := Vector2.ZERO
		
		if Input.is_action_just_pressed("ui_up"):
			input.y -= 1
		if Input.is_action_just_pressed("ui_down"):
			input.y += 1
		if Input.is_action_just_pressed("ui_left"):
			input.x -= 1
		if Input.is_action_just_pressed("ui_right"):
			input.x += 1
		
		if current_menu_parent is VBoxContainer:
			set_cursor_from_index(cursor_index + int(input.y))
		elif current_menu_parent is HBoxContainer:
			if row_count > 1:
				set_cursor_row(menu_index + int(input.y))
			set_cursor_from_index(cursor_index + int(input.x))
		elif current_menu_parent is GridContainer:
			set_cursor_from_index(cursor_index + int(input.x) + int(input.y) * current_menu_parent.columns)

func get_menu_item_at_index(index : int) -> Control:
	if current_menu_parent == null:
		return null
	
	if index >= current_menu_parent.get_child_count() or index < 0:
		return null
	
	return current_menu_parent.get_child(index) as Control

func set_cursor_from_index(index : int) -> void:
	var option_count = current_menu_parent.get_child_count()
	if index >= option_count:
		if row_count > 1:
			if current_menu_parent == menu_parent:
				menu_index = 1
			elif current_menu_parent == second_menu_parent:
				if row_count > 2:
					menu_index = 2
				else:
					menu_index = 0
			elif current_menu_parent == third_menu_parent:
				menu_index = 0
		index = 0
	elif index < 0:
		if row_count > 1:
			if current_menu_parent == menu_parent:
				if row_count > 2:
					menu_index = 2
				else:
					menu_index = 1
			elif current_menu_parent == second_menu_parent:
					menu_index = 0
			elif current_menu_parent == third_menu_parent:
				menu_index = 1
		index = option_count - 1
	
	var menu_item := get_menu_item_at_index(index)
	
	if menu_item == null:
		return
	
	var position = menu_item.rect_global_position
	var size = menu_item.rect_size
	position = position + Vector2(size.x, 0)
	
	rect_global_position = Vector2(position.x, position.y + size.y / 2.0) - (rect_size / 2.0) - cursor_offset
	
	cursor_index = index


func set_cursor_row(index: int):
	if index == -1:
		index = row_count - 1
	elif index == row_count:
		index = 0
	menu_index = index
	match index:
		0:
			current_menu_parent = menu_parent
		1:
			current_menu_parent = second_menu_parent
		2:
			current_menu_parent = third_menu_parent
