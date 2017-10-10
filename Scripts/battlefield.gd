extends Control

var bActor = load("res://Scenes/battleActor.tscn")

#turn variables
var turn = 1
var turnLength
var toNextTurn

#actor lists
var foeParty = [] #the list of foes passed to here

var foeList = [] #the list of battleActors with the foe info
var allyList = [] #the list of battleActors with ally info

var curBattleList = [] #the list of all battleActors
var turnOrder = [] #another list of all battleActors, in turn order (may contain duplicates)

var actor = null

var playerTurn = false

onready var cSel = get_node("charSelector")

#press onces bools
var interact = false
var up = false
var down = false
var left = false
var right = false
var menu = false

var tSel = 0
var select = false
var selTarget = "" #should be "FOE", "ALLY", "FIELD", or "ALL"

#button list
var buttons = []

func _ready():
	randomize()
	foeParty.push_back(DB.foes[0].make_new(1))
	foeParty.push_back(DB.foes[0].make_new(1))
	foeParty.push_back(DB.foes[0].make_new(1))
	foeParty.push_back(DB.foes[0].make_new(1))
	
	var allyHolder = get_node("allyHolder")
	var foeHolder = get_node("foeHolder")
	var set = 0
	
	var ah = allyHolder.get_children()
	for i in GAME_DATA.party:
		if i.id != 100:
			ah[set].ref = i
			ah[set].ref._reset_stats("ALL")
			ah[set].update_me()
			curBattleList.append(ah[set])
			allyList.append(ah[set])
			ah[set].connect("currentState",self,"process_actor_state")
			set += 1
	set = 0
	
	for n in allyHolder.get_children():
		if n.ref == null:
			n.queue_free()
		else:
			n.BA_STATE = "IDLE"
	
	var fh = foeHolder.get_children()
	for i in foeParty:
		if i.id != 100:
			fh[set].ref = i
			fh[set].ref._reset_stats("ALL")
			fh[set].update_me()
			curBattleList.append(fh[set])
			foeList.append(fh[set])
			set += 1
	
	for n in foeHolder.get_children():
		if n.ref == null:
			n.queue_free()
		else:
			n.BA_STATE = "IDLE"
	
	for i in get_node("battleOptions").get_children():
		buttons.append(i)
	
	turnLength = curBattleList.size()
	toNextTurn = turnLength
	print(str(foeList.size()))
	#clear_pos_nodes()
	make_turn_order()
	set_process_unhandled_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	turnOrder.front().get_node("labelHolder").set_hidden(false)
	check_button_hover()
	
	#if check_current_turn():
	#	update_char_selector(turnOrder.front())
	#	enemy_attack(turnOrder.front())
	
	#if !check_current_turn():
	if !select:
		if actor == null:
			cSel.set_hidden(true)
		elif actor != null:
			cSel.set_hidden(false)
			update_char_selector(actor)
	elif select:
		cSel.set_hidden(false)
		select_target("FOE")
	
	interact = false
	up = false
	down = false
	left = false
	right = false
	menu = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_menu"):
		menu = true
	elif event.is_action_released("ui_menu"):
		menu = false
	
	if event.is_action_pressed("ui_up"):
		up = true
	elif event.is_action_released("ui_up"):
		up = false
	
	if event.is_action_pressed("ui_down"):
		down = true
	elif event.is_action_released("ui_down"):
		down = false
	
	if event.is_action_pressed("ui_left"):
		left = true
	elif event.is_action_released("ui_left"):
		left = false
	
	if event.is_action_pressed("ui_right"):
		right = true
	elif event.is_action_released("ui_right"):
		right = false
		
	if event.is_action_pressed("ui_interact"):
		interact = true
	elif event.is_action_released("ui_interact"):
		interact = false

func get_actor_list(node):
	for i in get_node("allyHolder").get_children():
		if i.get_name() == node:
			return i
	for i in get_node("foeHolder").get_children():
		if i.get_name() == node:
			return i

func make_turn_order():
	if !turnOrder.empty():
		turnOrder.clear()
	#create a custom array to hold speed values
	var speedList = []
	for i in curBattleList:
		speedList.append(i.ref.SD)
		
	#sort the array. it sorts slowest(lower) in the front and fastest(higher) in the front
	speedList.sort()
	#then while the array still contains data, loop through the battleActors
	#and match the speed value to them, then append them to the master turn order list
	#delete the last variable from the array until all variables are accounted for
	while(!speedList.empty()):
		for i in curBattleList:
			if i.ref.SD == speedList.back():
				turnOrder.append(i)
				speedList.pop_back()
	if toNextTurn != turnLength:
		for tnx in range(0,toNextTurn):
			turnOrder.push_back(turnOrder.front())
			turnOrder.pop_front()
	turn_order_list()

func turn_order_list():
	if !get_node("TurnOrder").get_children().empty():
		for i in get_node("TurnOrder").get_children():
			i.queue_free()
	
	var port = load("res://Scenes/PartyItem.xml")
	var x = 70
	for i in turnOrder:
		var node = port.instance()
		node.set_pos(Vector2(x,global.screen_h-35))
		node.set_scale(Vector2(1,1))
		node.get_node("portBG").set_hidden(true)
		node.get_node("turnBG").set_hidden(false)
		node.get_node("charPortrait").set_frame(i.ref.portrait)
		node.get_node("battleMask").set_enabled(true)
		get_node("TurnOrder").add_child(node)
		x += 64

func update_char_selector(obj):
	cSel.set_pos(obj.get_pos())
	#obj.show_labels(true)

func check_button_hover():
	get_node("buttonLabel").set_text("")
	for i in buttons:
		if i.is_hovered():
			get_node("buttonLabel").set_text(i.buttonName)

func advanceTurn():
	for i in curBattleList:
		if i != actor and i.BA_STATE != "RETURN":
			i.revertState()
	
	if actor != null:
		actor = null
	
	toNextTurn -= 1
	if toNextTurn <= 0:
		turn+= 1
		toNextTurn = turnLength
	get_node("turnLabel").set_text(str(turn))

func _on_pass_pressed():
	actor.wait()
	advanceTurn()

func _on_attack_pressed():
	print(actor.ref.name + " attacking!")
	select = true
	#select_target("FOE")

func check_current_turn():
	var fof = false
	for i in foeList:
		if i.ref.name == turnOrder.front().ref.name:
			fof = true
	return fof

func select_target(selTarget):
	#select = true
	if selTarget == "FOE":
		if tSel > foeList.size()-1:
			tSel = foeList.size()-1
		if up:
			if tSel > 0:
				tSel -= 1
			else:
				tSel = foeList.size()-1
		if down:
			if tSel < foeList.size()-1:
				tSel += 1
			else:
				tSel = 0
		update_char_selector(foeList[tSel])
		
		if interact and !foeList[tSel].defeated:
			actor.attack(foeList[tSel])
			select = false
			get_node("battleOptions").set_hidden(true)
	elif selTarget == "ALLY":
		if up:
			if tSel > 0:
				tSel -= 1
			else:
				tSel = allyList.size()-1
		if down:
			if tSel < allyList.size()-1:
				tSel += 1
			else:
				tSel = 0
		update_char_selector(allyList[tSel])
		
		if interact and !allyList[tSel].defeated:
			actor.attack(allyList[tSel])
			select = false
			get_node("battleOptions").set_hidden(true)

func enemy_attack(enemy):
	#'enemy' accepts a battleActor instance
	if !enemy.defeated:
		print(enemy.ref.name +" lashes out with an attack!")
		enemy.attack(allyList[round(rand_range(0,allyList.size()-1))])
	#advanceTurn()

func process_actor_state(state):
	if state == "ACTION":
		for i in curBattleList:
			if i.BA_STATE == state and actor == null:
				print(i.ref.name + " is ready to act!")
				actor = i
			else:
				i.changeState("HOLD")
		get_node("battleOptions").set_hidden(false)
	elif state == "ATTACK":
		advanceTurn()