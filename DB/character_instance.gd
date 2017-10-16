extends Node

var id = 0
var name = ""
var spec = ""
var portrait = 0
var battleSprite

var desc = ""
var shortDesc = ""

var skills = [] #maybe?

var level = 1
var xp = 0
var xpToNext = 100

var defeated = false #whether or not a character is defeated
var defeatCount = 0 #how many times a character has been defeated
#if above defeated a character cannot be healed from defeat inside of combat

#Stats
#only permament stat increases (leveling up, perm stat up items?) will modify the base (exported) values
#the other values are used for everything else
var _HP = 0 #Base Max Health
var HP = _HP #Current Max Health
var cHP = HP #Current Health

var _EN = 0 #Base Max Energy
var EN = _EN #Current Max Energy
var cEN = EN #Current Energy

#Base States
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

#Derived Stats
var _AR = 0 #Base Armor
var AR = _AR #Current Armor
var _PR = 0 #Base Parry
var PR = _PR #Current Parry
var _WD = 0 #Base Ward
var WD = _WD #Current Ward
var _RF = 0 #Base Reflect
var RF = _RF #Current Reflect

#Resistance is how easily a character can shrug off status effects
#RES is the total base and there should be a resist for each class of status effects that derive from this
var _RES = 0 #Base Resist
var RES = 0 #Current Resistance


var rEN = 1 #Energy regen

#ENEMY ONLY
var threatened = [0,0,0,0,0]

var minAtk
var maxAtk

class move_instance:
	var id = 0
	var power = 0
	var cost = 0
	var cooldown = 0
	var threat = 0
	
	func get_name():
		return DB.abilities[id].name
	
	func get_desc():
		return DB.abilities[id].desc
	
	func get_power():
		return DB.abilities[id].power
	
	func get_cost():
		return DB.abilities[id].cost
	
	func get_cooldown():
		return DB.abilities[id].cooldown
	
	func get_threat():
		return DB.abilities[id].threat
	
	func get_type():
		return DB.abilities[id].type
	
	func get_ttype():
		return DB.abilities[id].targetType

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
	_calculate_derived_stats()
	_calculate_new_atk_values()

func _calculate_derived_stats():
	_AR = round(HP*0.01) #+ armor value from equipment
	AR = _AR
	_PR = round(DG*0.1)
	PR = _PR

func _calculate_new_atk_values():
	minAtk = round(MG*0.75)
	maxAtk = round(MG*1.25)

func get_crit_chance(): return AM*0.01

func get_dodge_chance(): return DG*0.01

func get_parry_chance(): return PR*0.01

func get_echo_chance(): return EC*0.01

func get_reflect_chance(): return RF*0.01

func threaten(n,t):
	for i in range(threatened.size()-1):
		#if the current iteration of the threatened value is initialized (aka is above 0)
		#it checks whether or not the location of the iterated value is equal to the one provided (n)
		#if it is, it will increase the iterated value by the given value (t)
		#if it is not, it will check to make sure that the given value (t) is above 0 (to avoid the value becoming uninitialized)
		#if the given value (t) IS above 0, it will reduce the current iterated value by half of the given value
		if threatened[i] > 0:
			if i != n and t > 0:
				if (threatened[i]-(t*0.5)) <= 0:
					threatened[i] = 1
				else: 
					threatened[i] -= t*0.5
				print(name+" lost "+str(t*0.5)+" threat at place "+str(i)+"!")
			elif i == n:
				if threatened[i]+t <= 0:
					threatened[i] = 1
				else:
					threatened[i] += t
				print(name+" was threatened by "+str(t)+" at place "+str(n)+"!")

func getHighestThreat():
	print("owo")
	var t = 0
	var tc = []
	for i in threatened:
		if i > t:
			t = i
	for i in threatened:
		if i == t:
			tc.push_back(1)
		else:
			tc.push_back(0)
	return tc

func defeat():
	defeated = true
	defeatCount += 1

func make_new(level):
	pass