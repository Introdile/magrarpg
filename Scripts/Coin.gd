extends Node2D

export var value = 1

var taken = false
var player = preload("res://Scripts/Player.gd")
var coinAnim
var owner

func _ready():
	coinAnim = get_node("sprite/animplayer")
	owner = get_owner()
	#if owner != null:
	#	owner.coinTotal += value

func _collect_coin( body ):
	if(!taken && owner != null):
		coinAnim.play("taken")
		global.coinCount += value
		owner.get_node("gui/coinCount").set_text(str(global.coinCount))
		print("Coins collected: "+str(global.coinCount))
		taken = true