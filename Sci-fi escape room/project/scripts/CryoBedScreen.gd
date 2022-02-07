extends Control

onready var login_screen = get_node("Start")
onready var login_id = get_node("Start/LineEdit")
onready var login_button = get_node("Start/Button")
onready var login_error = get_node("Start/Error")
onready var login_loading = get_node("Start/Loading")

onready var main_screen = get_node("Panel")
onready var main_text = get_node("Panel/HBoxContainer/VBoxContainer2/Panel/Label")

var network_timer = Timer.new()
var correct_login_id = "albino"


func _ready():
	network_timer.set_one_shot(true)
	get_parent().call_deferred("add_child", network_timer)


func _on_Button_pressed(button_id):
	main_text.text = "Page id: " + str(button_id)


func _on_Start_pressed(text = login_id.text):
	login_error.hide()
	login_loading.show()
	login_id.set_text("")
	login_id.set_editable(false)
	login_button.set_disabled(true)
	
	_network_wait()
	yield(network_timer, "timeout")
	login_loading.hide()
	login_id.set_editable(true)
	login_button.set_disabled(false)
	
	if text == correct_login_id:
		login_screen.hide()
		main_screen.show()
	else:
		login_error.show()


func _network_wait():
	var seconds = randi() % 3
	var decimal = randf()
	var wait_time = float(seconds + decimal)
	network_timer.set_wait_time(wait_time)
	network_timer.start()


func _on_TextEdit_focus_entered():
	GameState.state = GameState.STATES.TYPING
	print('focus_entered')


func _on_TextEdit_focus_exited():
	GameState.state = GameState.STATES.FREEWALK
	print('focus_exited')


func de_select():
	if login_screen.visible:
		login_id.release_focus()
