extends Node

export(int) var id = 0
export(String) var name = ""
export(String) var spec = ""
export(int) var portrait = 0
export(Texture) var battleSprite

export(String,MULTILINE) var desc = ""
export(String) var shortDesc = ""

export(Array) var skillList = [] #maybe?

#Stats
#only permament stat increases (leveling up, perm stat up items?) will modify the base (exported) values
#the other values are used for everything else
export(int) var _HP = 0 #Base Max Health

export(int) var _EN = 0 #Base Max Energy

export(int) var _MG = 0 #Base Might
export(int) var _AM = 0 #Base Aim
export(int) var _PT = 0 #Base Potency
export(int) var _EC = 0 #Base Echo
export(int) var _DG = 0 #Base Dodge
export(int) var _SD = 0 #Base Speed

var rEN = 1 #Energy regen

var minAtk
var maxAtk

var char_instance_sc = preload("res://DB/char_instance.gd")

func _ready():
	pass

func make_new(level):
	var n = char_instance_sc.new()
	n.name = name
	n.spec = spec
	n.portrait = portrait
	n.battleSprite = battleSprite
	
	n.desc = desc
	n.shortDesc = shortDesc
	
	n.id = id
	
	n.level = level
	
	n._HP = _HP
	n._EN = _EN
	
	n._MG = _MG
	n._AM = _AM
	n._PT = _PT
	n._EC = _EC
	n._DG = _DG
	n._SD = _SD
	n._reset_stats("ALL")
	return n