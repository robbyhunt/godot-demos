extends Node

enum STATES {FREEWALK, TALK}

var state = STATES.FREEWALK


func change_state(new_state):
	state = new_state
