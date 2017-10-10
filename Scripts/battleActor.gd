	extends Node2D

onready var ref
var defeated = false
var BA_STATE = "HOLD" #IDLE | ACTION | ATTACK | RETURN | HOLD | DEFEATED
signal currentState(state)

var damageText = preload("res://Scenes/damageTaken.xml")

onready var anim = get_node("sBattle/AnimationPlayer")
onready var atb_p = get_node("atb")

var startPos
var atb = 0

#attacks the target which is another unit
func attack(target):
	BA_STATE = "ATTACK"
	var attackPower = round(rand_range(ref.minAtk,ref.maxAtk))

	var absorbed = 0 #round(attackPower)*(target.Armor*0.1))

	var totalDamage = attackPower - absorbed
	var critChance = ref.AM*2
	
	var dodged = false
	var critical = false
	
	var attack = anim.get_animation("attack")
	
	var ch = round(rand_range(1,100))
	if ch < critChance:
		print(ref.name + " lashed out viciously! Critical hit!")
		totalDamage = totalDamage * 2
		critical = true
	#print(ch)
	#if ch < target.ref.DG*0.1:
	#	totalDamage = 0
	#	dodged = true
	attack.track_insert_key(0,0.5,Vector2((get_pos().x+target.get_pos().x)/2,((get_pos().y+target.get_pos().y)/2)-32)-get_pos())
	attack.track_insert_key(0,1,target.get_pos()-get_pos())
	anim.play("attack")
	
	target.takeDamage(totalDamage,critical,dodged)
	#return [target,totalDamage,critical]

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
	startPos = get_pos()
	set_fixed_process(true)

func _fixed_process(delta):
	process_state()

func process_state():
	if BA_STATE == "IDLE":
		if anim.get_current_animation() != "idle":
			anim.play("idle")
		if atb+(ref.SD*0.1) < 100:
			atb += ref.SD*0.1
		elif atb+(ref.SD*0.1) >= 100:
			BA_STATE = "ACTION"
			emit_signal("currentState",BA_STATE)
			#print(BA_STATE)
		atb_p.set_value(atb)
	elif BA_STATE == "RETURN":
		emit_signal("currentState",BA_STATE)
		anim.get_animation("return").track_insert_key(0,0,get_node("sBattle").get_pos())
		anim.play("return")

func update_me():
	get_node("sBattle").set_texture(ref.battleSprite)
	get_node("labelHolder/barHP").set_max(ref.HP)
	get_node("labelHolder/barEG").set_max(ref.EN)
	get_node("labelHolder/Name").set_text(ref.name)
	update_statLabels()

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

func attackDone():
	BA_STATE = "RETURN"

func returnDone():
	BA_STATE = "IDLE"