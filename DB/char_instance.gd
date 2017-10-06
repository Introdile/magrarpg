extends Node

var id = 0
var name = ""
var spec = ""
var portrait = 0
var battleSprite

var desc = ""
var shortDesc = ""

var skillList = [] #maybe?

var level = 1
var xp = 0
var xpToNext = 100

#Stats
#only permament stat increases (leveling up, perm stat up items?) will modify the base (exported) values
#the other values are used for everything else
var _HP = 0 #Base Max Health
var HP = _HP #Current Max Health
var cHP = HP #Current Health

var _EN = 0 #Base Max Energy
var EN = _EN #Current Max Energy
var cEN = EN #Current Energy

var _MG = 0 #Base Might
var MG = _MG #Current Might
var _AM = 0 #Base Aim
var AM = _AM #Current Aim
var _PT = 0 #Base Potency
var PT = _PT #Current Potency
var _EC = 0 #Base Echo
var EC = _EC #Current Echo
var _DG = 0 #Base Dodge
var DG = _DG #Current Dodge
var _SD = 0 #Base Speed
var SD = _SD #Current Speed

var rEN = 1 #Energy regen

var minAtk
var maxAtk

func _ready():
	_reset_stats("ALL")

func _reset_stats(stat):
	#'stat' takes a stat shorthand (HP for health or DG for dodge) and will set that stat to its base value
	#it can also take "ALL" to set all stats
	if stat == "HP":
		HP = _HP
		cHP = HP
	
	if stat == "EN":
		EN = _EN
		cEN = EN
	
	if stat == "MG":
		MG = _MG
	
	if stat == "AM":
		AM = _AM
	
	if stat == "PT":
		PT = _PT
	
	if stat == "EC":
		EC = _EC
	
	if stat == "DG":
		DG = _DG
	
	if stat == "SD":
		SD = _SD
	
	if stat == "ALL":
		HP = _HP
		cHP = HP
		EN = _EN
		cEN = EN
		MG = _MG
		AM = _AM
		PT = _PT
		EC = _EC
		DG = _DG
		SD = _SD
	_calculate_new_atk_values()

func _calculate_new_atk_values():
	minAtk = round(MG*0.75)
	maxAtk = round(MG*1.75)

func make_new(level):
	pass

