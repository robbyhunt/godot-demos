extends AudioStreamPlayer
class_name ACVoiceBox

signal characters_sounded(characters)
signal finished_phrase()


const PITCH_MULTIPLIER_RANGE := 0.3
const INFLECTION_SHIFT := 0.4

export(float, 2.5, 4.5) var base_pitch := 3.5

const sounds = {
	'high': {
		'a': preload('res://Audio/Voices/high/a.wav'),
		'b': preload('res://Audio/Voices/high/b.wav'),
		'c': preload('res://Audio/Voices/high/c.wav'),
		'd': preload('res://Audio/Voices/high/d.wav'),
		'e': preload('res://Audio/Voices/high/e.wav'),
		'f': preload('res://Audio/Voices/high/f.wav'),
		'g': preload('res://Audio/Voices/high/g.wav'),
		'h': preload('res://Audio/Voices/high/h.wav'),
		'i': preload('res://Audio/Voices/high/i.wav'),
		'j': preload('res://Audio/Voices/high/j.wav'),
		'k': preload('res://Audio/Voices/high/k.wav'),
		'l': preload('res://Audio/Voices/high/l.wav'),
		'm': preload('res://Audio/Voices/high/m.wav'),
		'n': preload('res://Audio/Voices/high/n.wav'),
		'o': preload('res://Audio/Voices/high/o.wav'),
		'p': preload('res://Audio/Voices/high/p.wav'),
		'q': preload('res://Audio/Voices/high/q.wav'),
		'r': preload('res://Audio/Voices/high/r.wav'),
		's': preload('res://Audio/Voices/high/s.wav'),
		't': preload('res://Audio/Voices/high/t.wav'),
		'u': preload('res://Audio/Voices/high/u.wav'),
		'v': preload('res://Audio/Voices/high/v.wav'),
		'w': preload('res://Audio/Voices/high/w.wav'),
		'x': preload('res://Audio/Voices/high/x.wav'),
		'y': preload('res://Audio/Voices/high/y.wav'),
		'z': preload('res://Audio/Voices/high/z.wav'),
		'th': preload('res://Audio/Voices/high/th.wav'),
		'sh': preload('res://Audio/Voices/high/sh.wav'),
		' ': preload('res://Audio/Voices/high/blank.wav'),
		'.': preload('res://Audio/Voices/high/longblank.wav')
	},
	'lowest': {
		'a': preload('res://Audio/Voices/lowest/a.wav'),
		'b': preload('res://Audio/Voices/lowest/b.wav'),
		'c': preload('res://Audio/Voices/lowest/c.wav'),
		'd': preload('res://Audio/Voices/lowest/d.wav'),
		'e': preload('res://Audio/Voices/lowest/e.wav'),
		'f': preload('res://Audio/Voices/lowest/f.wav'),
		'g': preload('res://Audio/Voices/lowest/g.wav'),
		'h': preload('res://Audio/Voices/lowest/h.wav'),
		'i': preload('res://Audio/Voices/lowest/i.wav'),
		'j': preload('res://Audio/Voices/lowest/j.wav'),
		'k': preload('res://Audio/Voices/lowest/k.wav'),
		'l': preload('res://Audio/Voices/lowest/l.wav'),
		'm': preload('res://Audio/Voices/lowest/m.wav'),
		'n': preload('res://Audio/Voices/lowest/n.wav'),
		'o': preload('res://Audio/Voices/lowest/o.wav'),
		'p': preload('res://Audio/Voices/lowest/p.wav'),
		'q': preload('res://Audio/Voices/lowest/q.wav'),
		'r': preload('res://Audio/Voices/lowest/r.wav'),
		's': preload('res://Audio/Voices/lowest/s.wav'),
		't': preload('res://Audio/Voices/lowest/t.wav'),
		'u': preload('res://Audio/Voices/lowest/u.wav'),
		'v': preload('res://Audio/Voices/lowest/v.wav'),
		'w': preload('res://Audio/Voices/lowest/w.wav'),
		'x': preload('res://Audio/Voices/lowest/x.wav'),
		'y': preload('res://Audio/Voices/lowest/y.wav'),
		'z': preload('res://Audio/Voices/lowest/z.wav'),
		'th': preload('res://Audio/Voices/lowest/th.wav'),
		'sh': preload('res://Audio/Voices/lowest/sh.wav'),
		' ': preload('res://Audio/Voices/lowest/blank.wav'),
		'.': preload('res://Audio/Voices/lowest/longblank.wav')
	}
}

const vowels = [
	'a',
	'e',
	'i',
	'o',
	'u'
]

var voice = "high"

var remaining_sounds := []


func _ready():
	connect("finished", self, "play_next_sound")


func play_string(in_string: String):
	parse_input_string(in_string)
	play_next_sound()


func play_next_sound():	
	if len(remaining_sounds) == 0:
		emit_signal("finished_phrase")
		return
	
	var next_symbol = remaining_sounds.pop_front()
	emit_signal("characters_sounded", next_symbol.characters)
	# Skip to next sound if no sound exists for text
	if next_symbol.sound == '':
		play_next_sound()
		return
	var sound: AudioStreamSample = sounds[voice][next_symbol.sound]
	# Add some randomness to pitch plus optional inflection for end word in questions
	pitch_scale = base_pitch + (PITCH_MULTIPLIER_RANGE * randf()) + (INFLECTION_SHIFT if next_symbol.inflective else 0.0)
	stream = sound
	play()


func parse_input_string(in_string: String):
	for word in in_string.split(' '):
		parse_word(word)
		add_symbol(' ', ' ', false)
	

func parse_word(word: String):
	var skip_char := false
	var is_inflective := word[-1] == '?'
	for i in range(len(word)):
		var lower_case_char = word[i].to_lower()
		if skip_char:
			skip_char = false
			continue
		# If not the last letter, check if next letter makes a two letter substring, e.g. 'th'
		if i < len(word) - 1:
			var two_character_substring = word.substr(i, i+2)
			if two_character_substring.to_lower() in sounds[voice].keys():
				add_symbol(two_character_substring.to_lower(), two_character_substring, is_inflective)
				skip_char = true
				continue
		if lower_case_char in vowels:
			add_symbol(' ', word[i], false)
		# Otherwise check if single character has matching sound, otherwise add a blank character
		elif lower_case_char in sounds[voice].keys():
			add_symbol(lower_case_char, word[i], is_inflective)
		else:
			add_symbol('', word[i], false)


func add_symbol(sound: String, characters: String, inflective: bool):
	remaining_sounds.append({
		'sound': sound,
		'characters': characters,
		'inflective': inflective
	})
