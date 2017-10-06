extends Patch9Frame

var printing = false
var donePrinting = false

onready var player = get_node("/root/World/TileMap/Player")

var pressed = false

var timer = 0
var textToPrint = []

var currentChar = 0
var currentText = 0

var th = 1

const TXT_SPEED = 0.1

func _ready():
	set_fixed_process(true)
	set_process_unhandled_key_input(true)

func _unhandled_key_input(key_event):
	if key_event.is_action_pressed("ui_interact"):
		pressed = true
	elif key_event.is_action_released("ui_interact"):
		pressed = false

func _fixed_process(delta):
	if printing:
		if !donePrinting:
			timer += delta
			if timer > TXT_SPEED:
				timer = 0
				get_node("RichTextLabel").set_bbcode(get_node("RichTextLabel").get_bbcode() + textToPrint[currentText][currentChar])
				currentChar += 1
				
			if currentChar >= textToPrint[currentText].length():
				currentChar = 0
				timer = 0
				donePrinting = true
				currentText += 1
			
			if pressed:
				_rush_to_end()
		elif pressed:
			donePrinting = false
			get_node("RichTextLabel").set_bbcode("")
			if currentText >= textToPrint.size():
				currentText = 0
				textToPrint = []
				printing = false
				set_hidden(true)
				player.canMove = true
	pressed = false

func _rush_to_end():
	if currentChar > th:
		get_node("RichTextLabel").set_bbcode(textToPrint[currentText])
		currentChar = 0
		timer = 0
		donePrinting = true
		currentText += 1

func _print_dialogue(text):
	printing = true
	textToPrint = text
	player.canMove = false
