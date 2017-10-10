extends Node

#holds active party members
var party = []

#hold inactive party members
var inactive = []

func _ready():
	#set Magra(0), Senra(1), and Rezisa(2)
	party.push_back(DB.characters[0].make_new(1))
	party.push_back(DB.characters[1].make_new(1))
	party.push_back(DB.characters[2].make_new(1))
	
	inactive.push_back(DB.characters[1].make_new(1))
	inactive.push_back(DB.characters[2].make_new(1))
	inactive.push_back(DB.characters[1].make_new(1))
	inactive.push_back(DB.characters[3].make_new(1))