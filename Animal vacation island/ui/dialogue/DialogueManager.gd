extends Control

var current_target: NPC
var player_ref: Player
var current_dialogues: Dictionary
var current_dialog: Dictionary

var current_voice_pitch 
var current_voice_pitch_variation
var current_voice_speed

var gamepad_timeout = false

var choice_base: PackedScene = preload("res://ui/dialogue/Choice.tscn")


# NODE REF VARIABLES
onready var message = $Box/HBoxContainer/Container1/Container2/Message
onready var speaker_name = $Box/Name
onready var voice_generator = $VoiceGeneratorAudioStreamPlayer


func _ready():
	# warning-ignore:return_value_discarded
	GameEvents.connect("dialogue_start", self, "_on_dialogue_start")
	# warning-ignore:return_value_discarded
	GameEvents.connect("dialogue_end", self, "_on_dialogue_end")
	# warning-ignore:return_value_discarded
	$Box/Cursor.connect("cursor_select", self, "_on_option_pressed")


func _on_dialogue_start(target: KinematicBody, player: KinematicBody):
	GameState.change_state(GameState.STATES.TALK)
	
	current_target = target
	player_ref = player
	
	var dialogue_file = File.new()
	dialogue_file.open("res://entities/npcs/" + target.npc_name + "/dialogue.json", dialogue_file.READ)
	var text = dialogue_file.get_as_text()
	var parse = JSON.parse(text)
	
	current_dialogues = parse.result
	current_dialog = current_dialogues.dialogues["default"]
	current_voice_pitch  = current_dialogues.voice_pitch
	current_voice_pitch_variation = current_dialogues.voice_pitch_variation
	current_voice_speed = current_dialogues.voice_speed
	dialogue_file.close()
	
	_update_ui()
	self.show()


func _update_ui():
	if len(current_dialog.signals) > 0:
		_handle_signals(current_dialog.signals)
	
	for choice_button in $Box/Choices.get_children():
		choice_button.queue_free()
	
	speaker_name.text = current_dialogues.name
	message.percent_visible = 0.00
	message.bbcode_text = current_dialog.message
	
	_handle_option_conditions(current_dialog.options)


func _handle_option_conditions(options: Array):
	for option in options:
		var add_dialog = true
		for condition in option.conditions:
			pass
		
		if add_dialog:
			var choice_instance = choice_base.instance()
			choice_instance.text = option.message
			choice_instance.set_meta("leads_to", option.leads_to)
			$Box/Choices.add_child(choice_instance)
	
	# Run function on voice generator to start playing sounds, which will call reveal() here when it is ready to progress
	voice_generator.read(current_dialog.message, load("res://ui/dialogue/v2.ogg"), current_voice_pitch, current_voice_pitch_variation, current_voice_speed)
	yield(get_tree().create_timer(.01), "timeout")
	gamepad_timeout = false


func reveal():
	message.percent_visible += 1.01 / float(len(current_dialog.message))


func _on_dialogue_end():
	current_target.on_dialogue_end()
	player_ref.on_dialogue_end()
	hide()
	yield(get_tree().create_timer(.01), "timeout")
	GameState.change_state(GameState.STATES.FREEWALK)


func _on_option_pressed(option_index: int, _menu_index: int):
	gamepad_timeout = true
	var new_dialog_id = $Box/Choices.get_child(option_index).get_meta("leads_to")
	
	# check if option carries "signals"
	if len(current_dialog.options[option_index].signals) > 0:
		_handle_signals(current_dialog.options[option_index].signals)
	
	if new_dialog_id == "end_dialog":
		GameEvents.emit_signal("dialogue_end")
	elif new_dialog_id != "":
		current_dialog = current_dialogues.dialogues[str(new_dialog_id)]
		_update_ui()


func _handle_signals(signals: Array):
	for _signal in signals:
		match _signal.type:
			"npc_anim":
				if current_target.has_method("play_anim"):
					current_target.play_anim(_signal.value)
