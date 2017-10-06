extends Node2D

onready var ref
var defeated = false

var damageText = preload("res://Scenes/damageTaken.xml")

#export(String, "Magic", "Melee", "Ranged") var AttackType
#export(String, MULTILINE) var UnitName = ''
#export(Texture) var UnitImage

#attacks the target which is another unit
func attack(target):
	var attackPower = round(rand_range(ref.minAtk,ref.maxAtk))

	var absorbed = 0 #round(attackPower)*(target.Armor*0.1))

	var totalDamage = attackPower - absorbed
	var critChance = ref.AM*2
	
	var dodged = false
	var critical = false
	
	var ch = round(rand_range(1,100))
	if ch < critChance:
		print(ref.name + " lashed out viciously! Critical hit!")
		totalDamage = totalDamage * 2
		critical = true
	#print(ch)
	#if ch < target.ref.DG*0.1:
	#	totalDamage = 0
	#	dodged = true
	
	target.takeDamage(totalDamage,critical,dodged)
	consumeEnergy(1)

func consumeEnergy(amount):
	ref.cEN = ref.cEN - amount
	get_node("labelHolder/barEG").set_value(ref.cEN)

func wait():
	ref.cEN = ref.cEN + ref.rEN
	if ref.cEN > ref.EN:
		ref.cEN = ref.EN
	get_node("labelHolder/barEG").set_value(ref.cEN)
	print("Regained "+str(ref.rEN)+" energy!")

func takeDamage(amount,critical,dodged):
	ref.cHP = ref.cHP - amount
	if ref.cHP > 0 :
		get_node("labelHolder/barHP").set_value(ref.cHP)
		if dodged:
			print("Dodged!")
		else:
			print(ref.name + " has taken "+str(amount)+" damage!")
	else:
		die()
	if ref.cHP < 0:
		ref.cHP = 0
	
	var dT = damageText.instance()
	dT.set_pos(self.get_pos()+dT.get_pos())
	dT.set_text(str(amount))
	if critical:
		dT.get_node("AnimationPlayer").play("crit")
	else:
		dT.get_node("AnimationPlayer").play("float")
	add_child(dT)

func die():
	if !defeated:
		print("Do something with death here")
		get_node("sBattle").set_rot(get_node("sBattle").get_rot()-90)
		get_node("sBattle").set_pos(Vector2(get_node("sBattle").get_pos().x,get_node("sBattle").get_pos().y+32))
		get_node("sBattle/AnimationPlayer").stop_all()
		defeated = true
	#get_node("HP").set_text("Dead")
	#get_node("Sprite").set_frame((20*13)+5)

func _ready():
	randomize()
	ref._reset_stats("ALL")
	#ref.SD = round(rand_range(1,100))
	print(ref.name + "'s speed is now "+str(ref.SD))
	get_node("labelHolder/barHP").set_max(ref.HP)
	get_node("labelHolder/barEG").set_max(ref.EN)
	get_node("labelHolder/Name").set_text(ref.name)
	update_statLabels()
	set_process_input(true)

func _on_hurtSenra_pressed():
	takeDamage(10,false)

func update_statLabels():
	get_node("labelHolder/barHP").set_value(ref.cHP)
	get_node("labelHolder/barEG").set_value(ref.cEN)
	get_node("labelHolder/MG").set_text(str(ref.MG))
	get_node("labelHolder/CR").set_text(str(ref.AM))
	get_node("labelHolder/PT").set_text(str(ref.PT))
	get_node("labelHolder/EC").set_text(str(ref.EC))
	get_node("labelHolder/DG").set_text(str(ref.DG))
	get_node("labelHolder/SD").set_text(str(ref.SD))

func show_labels(t):
	get_node("labelHolder").set_hidden(t)

func _on_hoverArea_mouse_enter():
	get_node("labelHolder").set_hidden(false)


func _on_hoverArea_mouse_exit():
	get_node("labelHolder").set_hidden(true)