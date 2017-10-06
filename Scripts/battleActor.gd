extends Node2D

onready var ref
var defeated = false

#export(String, "Magic", "Melee", "Ranged") var AttackType
#export(String, MULTILINE) var UnitName = ''
#export(Texture) var UnitImage

#attacks the target which is another unit
func attack(target):
	var attackPower = rand_range(ref.minAtk,ref.maxAtk)

	var absorbed = 0 #round(attackPower)*(target.Armor*0.1))

	var totalDamage = attackPower - absorbed
	
	var dodged = false
	
	var ch = rand_range(3,18)
	print(ch)
	if ch < target.ref.DG*0.1:
		totalDamage = 0
		dodged = true
	
	target.takeDamage(totalDamage,dodged)
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
	#get_node("CombatText").set_text("Rested...restored "+str(1+Intelligence)+" Exertion")

func takeDamage(amount,dodged):
	ref.cHP = ref.cHP - amount
	if ref.cHP > 0 :
		get_node("labelHolder/barHP").set_value(ref.cHP)
		if dodged:
			print("Dodged!")
		else:
			print("-"+str(amount)+" damage taken!")
	else:
		die()
	if ref.cHP < 0:
		ref.cHP = 0

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

func _on_hoverArea_mouse_enter():
	get_node("labelHolder").set_hidden(false)


func _on_hoverArea_mouse_exit():
	get_node("labelHolder").set_hidden(true)