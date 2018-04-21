extends Node

export(int) var id = -1
export(String) var name = ""
export(int) var spec = 0 #Starting Spec ID
export(Array) var portrait
export(Texture) var battleSprite

export(String,MULTILINE) var desc = ""
export(String) var shortDesc = ""

export(Array) var learn_skill_ids = []
export(Array) var learn_levels = []

#TODO: ADD ANIMATIONS TO THE DB
#- add a sprite child node to the character database node
#- add an animation node as a child to the sprite node
#- add a reference to said node here
#instead of custom setting animations thru code, manually add animations, use generic names for animations for ease of referencing
#when setting up the battlers, pull the node to the database and make it replace the battler's default sprite

#Stats
#only permament stat increases (leveling up, perm stat up items?) will modify the base (exported) values
#the other values are used for everything else

#APTITUDES are a character's base strengths in each stat.

#APTITUDES come in WEAK, AVG, and STRONG.
#They give different a base between HEALTH, ENERGY, and the other stats.
#WEAK APTITUDE gives a base 48 for HEALTH, 16 for ENERGY, and 4 for STATS.
#AVG APTITUDE gives a base 64 for HEALTH, 32 for ENERGY, and 8 for STATS.
#STRONG APTITUDE gives a base 80 for HEALTH, 48 for ENERGY, and 10 for STATS.

export(int, "WEAK", "AVG", "STRONG") var _HP_apt = 0 #Health Aptitude
export(int, "WEAK", "AVG", "STRONG") var _EN_apt = 0 #Energy Aptitude

export(int, "WEAK", "AVG", "STRONG") var _MG_apt = 0 #Might Aptitude
export(int, "WEAK", "AVG", "STRONG") var _AM_apt = 0 #Aim Aptitude

export(int, "WEAK", "AVG", "STRONG") var _PT_apt = 0 #Potency Aptitude
export(int, "WEAK", "AVG", "STRONG") var _EC_apt = 0 #Echo Aptitude

export(int, "WEAK", "AVG", "STRONG") var _DG_apt = 0 #Dodge Aptitude
export(int, "WEAK", "AVG", "STRONG") var _SD_apt = 0 #Speed Aptitude

#			   0 = HP  1 = EN  2 = MG  3 = AM  4 = PT  5 = EC  6 = DG  7 = SD
var p_stats = [_HP_apt,_EN_apt,_MG_apt,_AM_apt,_PT_apt,_EC_apt,_DG_apt,_SD_apt]

var rEN = 1 #Energy regen

var minAtk
var maxAtk

var char_instance_sc = preload("res://DB/character_instance.gd")

func _ready():
	pass

func make_new(level):
	var n = char_instance_sc.new()
	n.name = name
	n.specId = spec
	n.portrait = portrait
	n.battleSprite = battleSprite
	
	n.desc = desc
	n.shortDesc = shortDesc
	
	n.id = id
	
	n.stat_apt = p_stats
	
	n.level = level
	
	
	var learnSkills = []
	
	for i in range(learn_skill_ids.size()):
		if learn_levels[i] <= level:
			for x in DB.abilities:
				if x.id == learn_skill_ids[i]:
					learnSkills.push_back(x)
	
	for i in learnSkills:
		var skill = char_instance_sc.move_instance.new()
		skill.id = i.id
		skill.power = i.power
		skill.cost = i.cost
		skill.cooldown = i.cooldown
		skill.threat = i.threat
		n.skills.push_back(skill)
	
	n._reset_stats("ALL")
	return n
