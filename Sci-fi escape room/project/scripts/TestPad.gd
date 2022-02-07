extends Control

export(NodePath) var door_path
onready var door: MeshInstance = get_node(door_path)

func _ready():
	if door.is_locked:
		$Panel/CenterContainer/VBoxContainer/Label.text = "Door Locked"
	elif not door.is_locked:
		$Panel/CenterContainer/VBoxContainer/Label.text = "Door Open"


func _on_Button_pressed():
	if not door.is_locked:
		if not door.is_open:
			door.is_locked = true
			$Panel/CenterContainer/VBoxContainer/Label.text = "Door Locked"
	elif door.is_locked:
		door.is_locked = false
		$Panel/CenterContainer/VBoxContainer/Label.text = "Door Open"
