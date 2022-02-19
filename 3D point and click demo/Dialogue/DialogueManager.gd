extends Control


onready var voicebox: ACVoiceBox = $ACVoicebox

var speaker
var conversation = [
	[0, "base"],
	[1, "reply"]
   ]

var current_label: Label

var in_dialogue = false


func _ready():
	voicebox.connect("characters_sounded", self, "_on_voicebox_characters_sounded")
	voicebox.connect("finished_phrase", self, "_on_voicebox_finished_phrase")


func _on_voicebox_characters_sounded(characters: String):
	current_label.text += characters


func _on_voicebox_finished_phrase():
	if conversation.size() > 0:
		play_next_in_conversation()
	


func play_next_in_conversation():
	var next_line = conversation.pop_front()
	# if player speaking use defaults
	if next_line[0] == 0:
		voicebox.voice = "high"
		voicebox.base_pitch = 4
	else:
		voicebox.voice = speaker.voice
		voicebox.base_pitch = speaker.voice_pitch
	current_label = $Labels.get_child(next_line[0]).get_node("Label")
	current_label.get_parent().show()
	voicebox.play_string(next_line[1])


func start_dialogue(dialogue_object):
	_clear()
	var new_conversation = [] + dialogue_object.conversation
	speaker = dialogue_object
	conversation = new_conversation
	in_dialogue = true
	play_next_in_conversation()


func end_dialogue():
	if in_dialogue:
		_clear()
		in_dialogue = false


func _clear():
	speaker = null
	conversation = []
	voicebox.remaining_sounds = []
	for label in $Labels.get_children():
		label.get_node("Label").text = ""
		label.hide()
