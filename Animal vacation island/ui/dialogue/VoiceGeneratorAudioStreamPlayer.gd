extends AudioStreamPlayer

signal finished_phrase

var _phrase: String = ""
var _phrase_pos: int = 0
var _phrase_wait: float = -1

var sound_duration

var _original_pitch_scale: float

var _punctuations: Dictionary = {
	" ": 0.025, # duration of pause in seconds.
	",": 0.1,
	".": 0.3,
	"!": 0.3,
	"?": 0.3,
	"-": 0.1,
	"'": 0.0,
}

const VOWELS = ['a', 'e', 'i', 'o', 'u', 'y']
var prev_char_is_vowel : bool = false

func _process(delta: float) -> void:
	_phrase_wait -= delta
	
	if not _phrase or _phrase_wait > 0:
		return
	
	if not playing:
		if _phrase_pos < _phrase.length():
			_phrase_wait = sound_duration
			# check for guessed syllables
			#seek_next_syllable()
			if _punctuations.has(_phrase[_phrase_pos]):
				if _original_pitch_scale:
					pitch_scale = _original_pitch_scale
					_original_pitch_scale = 0
				_phrase_wait = _punctuations[_phrase[_phrase_pos]]
			else:
				var question_distance: int = get_distance_to_question(_phrase, _phrase_pos)
				if question_distance >= 0 and question_distance < 4:
					if not _original_pitch_scale:
						_original_pitch_scale = pitch_scale
					pitch_scale += 0.10 / float(question_distance)
				else:
					stop()
					play()
			_phrase_pos += 1
			yield(get_tree().create_timer(0.1), "timeout")
			get_parent().reveal()
		else:
			emit_signal("finished_phrase")
			_phrase = ""

func seek_next_syllable():
	var Char : String = _phrase[_phrase_pos].to_lower()
	
	while not (Char in VOWELS and not prev_char_is_vowel):
		# this searches for the next consonant-to-vowel transition (or space) to approximate syllables.
		prev_char_is_vowel = Char in VOWELS
		if Char.is_valid_integer() or Char == '-':
			return #treats each number character as its own syllable
		if Char in _punctuations:
			return
		if not _phrase_pos + 1 < _phrase.length():
			return
		
		_phrase_pos += 1
		Char = _phrase[_phrase_pos].to_lower()
		yield(get_tree().create_timer(0.1), "timeout")
		get_parent().reveal()
		
		# optional - covers silent 'e' at the end use case
		var nextChar = null
		if _phrase_pos + 1 < _phrase.length():
			nextChar = _phrase[_phrase_pos + 1]
		if Char == 'e' and nextChar in _punctuations:
			_phrase_pos += 1
			yield(get_tree().create_timer(0.1), "timeout")
			get_parent().reveal()
		
		prev_char_is_vowel = Char in VOWELS


func get_distance_to_question(text: String, from_pos: int):
	var closest_question_idx: int = -1
	var symbol_idx: int = from_pos + 1
	while symbol_idx < text.length():
		if text[symbol_idx] == "?":
			closest_question_idx = symbol_idx - _phrase_pos
			break
		symbol_idx += 1
	return closest_question_idx

func read(text: String, voice: Resource = load("res://ui/dialogue/v2.ogg"), pitch: float = 1.1, pitch_variation: float = 1.2, speed = 0.65) -> void:
	stream.audio_stream = voice
	$Overflow.stream.audio_stream = voice
	pitch_scale = pitch
	stream.random_pitch = pitch_variation
	sound_duration = stream.get_length() / float(speed)
	_phrase = text
	_phrase_pos = 0

func is_reading() -> bool:
	return !!_phrase

func is_waiting() -> bool:
	return _phrase_wait > 0
