
extends Node

var characters = []
var foes = []

var abilities = []

func _ready():
	#var dummy = Node.new()
	#characters.push_back(dummy)
	var char_container = get_node("Characters")
	var foe_container = get_node("Foes")
	var ab_container = get_node("Abilities")
	
	for char in char_container.get_children():
		characters.push_back(char)
		
	for foe in foe_container.get_children():
		foes.push_back(foe)
	
	for ab in ab_container.get_children():
		if "$" in ab.get_name():
			pass
		else:
			abilities.push_back(ab)
			print(ab.get_name()+" pushed successfully!")
