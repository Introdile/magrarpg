extends Node

var currentScene = null

#screensize
var resolution = Vector2(Globals.get("display/width"),Globals.get("display/height"))
var screen_w = Globals.get("display/width")
var screen_h = Globals.get("display/height")

#playervars
var coinCount = 0

#PARTY INFO:    ID                                        NAME           CLASS     TILE ID   HP   ENERGY   MG   CR   PT   EC   DG   SD 
#var party = [
#createPartyData(0, "res://Sprites/magraPlaceholder.png",  "Magra",      "Gunslinger",   1,   100,   50,    10,  5,   0,   0,   20,  20), 
#createPartyData(1, "res://Sprites/senra_idle_sheet.png",  "Senra",      "Apothecary",   2,   75,    100,   5,   1,   10,  5,   5,   10), 
#createPartyData(2, "res://Sprites/rezisaPlaceholder.png", "Rezisa",      "Berserker",   3,   150,   50,    15,  2,   5,   1,   10,  10), 
#createPartyData(3, "res://Sprites/magraPlaceholder.png",  "Happy Magra", "Cute Boy!!",  4,   1000,  500,   50,  50,  0,   0,   50,  50), 
#createPartyData(4, "res://Sprites/senra_idle_sheet.png",  "Happy Senra", "My Sunshine", 5,   500,   1000,  5,   1,   50,  50,  10,  10),  
#createPartyData(100,"res://Sprites/enemyPlaceholder.png"," "," ",0,0,0,0,0,0,0,0,0)]

#var activeParty = [party[0],party[1],party[2],party[4]]

var inv = [createInventoryItem("Toilet Paper",0,"A travelling essential!",0,1), createInventoryItem("Health Tonic",1,"A vial of healing fluid.",0,1), createInventoryItem("Energy Tonic",2,"A vial of energizing fluid.",0,1)]

func createPartyData(_ID, _BTile, _Name, _Class, _Tile, _HP, _EN, _MG, _CR, _PT, _EC, _DG, _SD):
	return {ID = _ID, BTile = _BTile, Name = _Name, Class = _Class, Tile = _Tile, HP = _HP, EN = _EN, MG = _MG, CR = _CR, PT = _PT, EC = _EC, DG = _DG, SD = _SD}

func createInventoryItem(_Name, _Tile, _Desc, _ID, _AMOUNT):
	return {Name = _Name, Tile = _Tile, Desc = _Desc, ID = _ID, AMOUNT = _AMOUNT}

func isPartyAtMinSize():
	pass
	#var empty = 0
	#	for i in activeParty:
	#	if i.ID == 100:
	#		empty += 1
	#if empty >= 3:
	#	return false
	#else:
	#	return true

func doesPlayerHaveItem(ID):
	for i in inv:
		if i.ID == ID:
			return true
	return false

func _add_basic_info(ID):
	pass

func _ready():
	pass