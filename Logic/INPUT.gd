extends Node

#onready var up = get_node("ui_up")
#onready var down = get_node("ui_down")
#onready var left = get_node("ui_left")
#onready var right = get_node("ui_right")

#onready var menu = get_node("ui_menu")
#onready var interact = get_node("ui_interact")

var button = true

func _ready():
	set_process_unhandled_input(true)

func _unhandled_key_input(key_event):
	