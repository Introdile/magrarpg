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
	for i in GAME_DATA.party:
		if i.id != 100:
			var node = bActor.instance()
			node.ref = i
			node.ref._reset_stats("ALL")
			#var btex = load(i.battleSprite)
			if set == 0:
				node.set_pos(get_node("allyHolder/ally1").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
				set += 1
			elif set == 1:
				node.set_pos(get_node("allyHolder/ally2").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
				set += 1
			elif set == 2:
				node.set_pos(get_node("allyHolder/ally3").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
				set+= 1
			elif set == 3:
				node.set_pos(get_node("allyHolder/ally4").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
			#node._Name = i.name
			node.get_node("sBattle").set_frame(randi()%4)
			#node.reset_stats(false)
			allyHolder.add_child(node)
			curBattleList.append(node)
			allyList.append(node)
	
	var fset = 0
	for i in foeParty:
		if i.id != 100:
			var node = bActor.instance()
			node.ref = i
			node.ref._reset_stats("ALL")
			#var btex = load(i.battleSprite)
			if fset == 0:
				node.set_pos(get_node("foeHolder/foe1").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
				fset += 1
			elif fset == 1:
				node.set_pos(get_node("foeHolder/foe2").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
				fset += 1
			elif fset == 2:
				node.set_pos(get_node("foeHolder/foe3").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
				fset+= 1
			elif fset == 3:
				node.set_pos(get_node("foeHolder/foe4").get_pos())
				node.get_node("sBattle").set_texture(i.battleSprite)
			#node._Name = i.name
			node.get_node("sBattle").set_frame(randi()%4)
			#node.reset_stats(false)
			foeHolder.add_child(node)
			curBattleList.append(node)
			foeList.append(node)
	
	for i in get_node("battleOptions").get_children():
		buttons.append(i)
	
	turnLength = curBattleList.size()
	toNextTurn = turnLength
	print(str(foeList.size()))
	clear_pos_nodes()
	make_turn_order()
	set_process_unhandled_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	turnOrder.front().get_node("labelHolder").set_hidden(false)
	check_button_hover()
	
	if check_current_turn():
		enemy_attack(turnOrder.front())
	
	if !select:
		update_char_selector(turnOrder.front())
	elif select:
		select_target()
	
	if interact:
		check_current_turn()
	
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
	#prints the turn order to the consol just to be sure
	print("Turn order:")
	for i in turnOrder:
		print(i.ref.name + " | Speed: "+ str(i.ref.SD))
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
		node.get_node("charPortrait").set_frame(i.ref.portrait)
		node.get_node("battleMask").set_enabled(true)
		get_node("TurnOrder").add_child(node)
		x += 70

func update_char_selector(obj):
	cSel.set_pos(obj.get_pos())
	#obj.show_labels(true)

func check_button_hover():
	get_node("buttonLabel").set_text("")
	for i in buttons:
		if i.is_hovered():
			get_node("buttonLabel").set_text(i.buttonName)

func clear_pos_nodes():
	get_node("allyHolder/ally1").free()
	get_node("allyHolder/ally2").free()
	get_node("allyHolder/ally3").free()
	get_node("allyHolder/ally4").free()
	get_node("foeHolder/foe1").free()
	get_node("foeHolder/foe2").free()
	get_node("foeHolder/foe3").free()
	get_node("foeHolder/foe4").free()
	#get_node("foeHolder/foe5").free()
	#get_node("foeHolder/foe6").free()

func advanceTurn():
	turnOrder.front().get_node("labelHolder").set_hidden(true)
	turnOrder.push_back(turnOrder.front())
	turnOrder.pop_front()
	turn_order_list()
	toNextTurn -= 1
	if toNextTurn <= 0:
		turn+= 1
		toNextTurn = turnLength
	get_node("turnLabel").set_text(str(turn))
	print("It is "+turnOrder.front().ref.name+"'s turn!")

func _on_pass_pressed():
	turnOrder.front().wait()
	advanceTurn()

func _on_attack_pressed():
	print(turnOrder.front().ref.name + " attacking!")
	select = true

func check_current_turn():
	var fof = false
	for i in foeList:
		if i.ref.name == turnOrder.front().ref.name:
			fof = true
	return fof

func select_target():
	if up:
		if tSel > 0:
			tSel -= 1
		else:
			tSel = foeList.size()-1
		print(str(tSel)+" "+str(foeList[tSel].get_name()))
	if down:
		if tSel < foeList.size()-1:
			tSel += 1
		else:
			tSel = 0
		print(str(tSel)+" "+str(foeList[tSel].get_name()))
	update_char_selector(foeList[tSel])
	
	if interact:
		turnOrder.front().attack(foeList[tSel])
		select = false
		advanceTurn()

func enemy_attack(enemy):
	#'enemy' accepts a battleActor instance
	print(enemy.ref.name +" lashes out with an attack!")
	enemy.attack(allyList[round(rand_range(0,allyList.size()-1))])
	advanceTurn()

