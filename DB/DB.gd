extends Node

var characters = []
var foes = []

func _ready():
	#var dummy = Node.new()
	#characters.push_back(dummy)
	var char_container = get_node("characters")
	var foe_container = get_node("foes")
	
	for char in char_container.get_children():
		characters.push_back(char)
		
	for foe in foe_container.get_children():
		foes.push_back(foe)