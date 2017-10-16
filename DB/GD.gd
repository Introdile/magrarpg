extends Node

#holds the active party
var party = []

#holds the inactive party
var inactive = []

func _ready():
	party.push_back(DB.characters[0].make_new(1))
	party.push_back(DB.characters[1].make_new(1))
	party.push_back(DB.characters[2].make_new(1))