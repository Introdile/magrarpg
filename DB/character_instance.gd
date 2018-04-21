extends Node

onready var calc = preload("res://DB/calculations.gd")

enum APTITUDE {WEAK,AVG,STRONG}

var id = -1
var name = ""
var specId = 0
var portrait = 0
var battleSprite

var desc = ""
var shortDesc = ""

var skills = [] #maybe?

var level = 1
var xp = 0
var xpToNext = 0

var defeated = false #whether or not a character is defeated
var defeatCount = 0 #how many times a character has been defeated
#if above defeated a character cannot be healed from defeat inside of combat

#Stats
#only permament stat increases (leveling up, perm stat up items?) will modify the base (exported) values
#the other values are used for everything else

# 0 = HP  1 = EN  2 = MG  3 = AM  4 = PT  5 = EC  6 = DG  7 = SD
var stat_apt = [0,0,0,0,0,0,0,0]
var stat_grw = [0,0,0,0,0,0,0,0]
# _stat is the base, umodified stats and stat is the modified stats
var _stat = [0,0,0,0,0,0,0,0]
var stat = [0,0,0,0,0,0,0,0]

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
	print(name+", spec: "+DB.spec[specId].name)
	_initialize_stats()
	xpToNext = calc.calculate_exp(level)

func _initialize_stats():
	#DB.spec[specId]
	stat_grw = DB.spec[specId].p_stats
	
	for i in range(_stat.size()):
		if i == 0:
			_stat[i] = calc.calculate_hp(stat_apt[i],stat_grw[i],level)
		elif i == 1:
			_stat[i] = calc.calculate_en(stat_apt[i],stat_grw[i],level)
		else:
			_stat[i] = calc.calculate_stat(stat_apt[i],stat_grw[i],level)
		print("Stat number "+str(i)+" set to "+str(_stat[i]))
	
	_reset_stats("ALL")

func _reset_stats(stat):
	#'stat' takes a stat shorthand (HP for health or DG for dodge) and will set that stat to its base value
	#it can also take "ALL" to set all stats
	if stat == "HP":
		stat[0] = _stat[0]
	
	if stat == "EN":
		stat[1] = _stat[1]
	
	if stat == "MG":
		stat[2] = _stat[2]
	
	if stat == "AM":
		stat[3] = _stat[3]
	
	if stat == "PT":
		stat[4] = _stat[4]
	
	if stat == "EC":
		stat[5] = _stat[5]
	
	if stat == "DG":
		stat[6] = _stat[6]
	
	if stat == "SD":
		stat[7] = _stat[7]
	
	if stat == "ALL":
		stat = _stat
	
	_calculate_derived_stats()
	_calculate_new_atk_values()

func _calculate_derived_stats():
	_AR = round(stat[0]*0.01) #+ armor value from equipment
	AR = _AR
	_PR = round(stat[6]*0.1)
	PR = _PR

func _calculate_new_atk_values():
	minAtk = round(stat[2]*0.75)
	maxAtk = round(stat[2]*1.25)

func get_crit_chance(): return stat[3]*0.01

func get_dodge_chance(): return stat[6]*0.01

func get_parry_chance(): return PR*0.01

func get_echo_chance(): return stat[5]*0.01

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
	var t = 0
	var tc = []
	for i in threatened:
		if i > t:
			t = i
	for i in range(threatened.size()-1):
		if threatened[i] == t:
			tc.push_back(i)
	print(str(tc))
	return tc

func defeat():
	defeated = true
	defeatCount += 1

func make_new(level):
	pass