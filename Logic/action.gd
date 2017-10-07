
extends Node

var action = ""

var pressed = false

func _ready():
	action = get_name()
	set_process_unhandled_key_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	pressed = false

func _unhandled_key_input(key_event):
	if key_event.is_action_pressed(action):
		pressed = true
	elif key_event.is_action_released(action):
		pressed = false

func is_pressed():
	return pressed