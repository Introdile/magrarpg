extends Node

onready var battleFunc = preload("res://LOGIC/BATTLE/battleFunc.gd")

#Battle State variables
enum BattleStates{
	START,
	ALLYCHOICE,
	FOECHOICE,
	ANIMATION,
	CALCDAMAGE,
	SELECT,
	NEXTTURN,
	PASS,
	LOSE,
	WIN
}

onready var currentState
onready var lastState

onready var pActions = get_node("PlayerPanels/Actions/PlayerActions")
onready var pip = get_node("Pip")
onready var sel = get_node("Sel")

#Actor lists
var allies = []
export var foes = []
var battlers = []

#Battle variables
var playerUsedAbility
var cA #current actor aka the person who's turn it is
var cAT #current actor target

#TURN COUNT
onready var nturn = get_node("TURN")
var turn = 0
var turnLength
var toNextTurn

var pipDes = Vector2(0,0)
var selDes = Vector2(0,0)

var setOnce = false

func _ready():
	randomize()
	currentState = BattleStates.START
	for c in GD.party:
		allies.push_back(c)
		battlers.push_back(c)
	foes.push_back(DB.foes[0].make_new(1))
	foes.push_back(DB.foes[0].make_new(1))
	foes[1].name = foes[1].name+" 2"
	foes.push_back(DB.foes[0].make_new(1))
	foes[2].name = foes[2].name+" 3"
	
	for i in range(0,foes.size()):
		foes[i].SD = round(rand_range(15,25))
		for ii in range(allies.size()):
			foes[i].threatened[ii] = 1
	
	for i in foes:
		battlers.push_back(i)
	battlers.sort_custom(battleFunc,"isSpeedGreater")
	turnLength = battlers.size()
	toNextTurn = turnLength
	for n in battlers:
		print(n.name+" "+str(n.SD))
	set_fixed_process(true)

func _fixed_process(delta):
	if pip.get_pos().distance_to(pipDes) > 5:
			moveObj(pip,pipDes,delta)
	
	if currentState == BattleStates.START:
		battleFunc.prepareBattlers(get_node("ALLY"),allies,true)
		battleFunc.prepareBattlers(get_node("FOE"),foes,false)
		sel.set_pos(get_node("FOE/"+foes[0].name).get_pos())
		selDes = get_node("FOE/"+foes[0].name).get_pos()
		
		for n in get_node("ALLY").get_children():
			n.connect("actor_clicked",self,"actorClicked")
		
		for n in get_node("FOE").get_children():
			n.connect("actor_clicked",self,"actorClicked")
		
		battleFunc.setUpBars(get_node("PlayerPanels/Info"),allies)
		
		cA = battlers.front()
		get_node("PlayerPanels/Actions/Name").set_text(cA.name+"'s turn!")
		if battleFunc.isCurrentTurnEnemy(allies,battlers):
			pip.set_pos(get_node("FOE/"+cA.name).get_pos()-Vector2(0,48))
			changeState(BattleStates.FOECHOICE)
		else:
			pip.set_pos(get_node("ALLY/"+cA.name).get_pos()-Vector2(0,48))
			changeState(BattleStates.ALLYCHOICE)
	elif currentState == BattleStates.ALLYCHOICE:
		#get_node("ALLY/"+battlers.front().name).slideToTarget(Vector2(128,0),delta)
		if !setOnce:
			pipDes = get_node("ALLY/"+cA.name).get_pos()-Vector2(0,48)
			battleFunc.listPlayerMoves(pActions,cA)
			setOnce = true
		
		if pip.get_pos().distance_to(pipDes) > 5:
			moveObj(pip,pipDes,delta)
		
		for i in pActions.get_children():
			if i.is_pressed():
				if i.get_name() != "Pass":
					for n in cA.skills:
						if i.get_name() == n.get_name():
							print(cA.name + " used " + n.get_name()+"!")
							playerUsedAbility = n
							print(str(playerUsedAbility.get_ttype()))
					changeState(BattleStates.SELECT)
					setOnce = false
					for x in pActions.get_children():
						x.queue_free()
				else:
					if cA.cEN < cA.EN:
						cA.cEN += cA.rEN
						if cA.cEN > cA.EN:
							cA.cEN = cA.EN
					changeState(BattleStates.NEXTTURN)
					setOnce = false
					for x in pActions.get_children():
						x.queue_free()
		
	elif currentState == BattleStates.FOECHOICE:
		if !setOnce:
			pipDes = get_node("FOE/"+cA.name).get_pos()-Vector2(0,48)
			var t = Timer.new()
			t.set_wait_time(1)
			t.start()
			t.connect("timeout",self,"timesUp")
			t.set_name("waitTimer")
			add_child(t)
			setOnce = true
		
	elif currentState == BattleStates.CALCDAMAGE:
		sel.set_hidden(true)
		if battleFunc.isCurrentTurnEnemy(allies,battlers):
			var ab = round(rand_range(0,cA.skills.size()-1))
			#print(allies[cA.getHighestThreat()].name+" has the most threat against me!")
			if cA.cEN > cA.skills[ab].get_cost():
				var dmg = battleFunc.calculateDamage(cA,cA.skills[ab],cAT)
				battleFunc.spawnText(get_node("ALLY/"+cAT.name),dmg,false)
				battleFunc.updateBars(get_node("PlayerPanels"),cAT,"hp")
				cA.cEN -= cA.skills[ab].get_cost()
				cAT.cHP -= dmg
				if cAT.cHP <= 0:
					cAT.cHP = 0
					cAT.defeat()
				changeState(BattleStates.NEXTTURN)
		elif !battleFunc.isCurrentTurnEnemy(allies,battlers):
			var dmg = battleFunc.calculateDamage(cA,playerUsedAbility,cAT)
			battleFunc.spawnText(get_node("FOE/"+cAT.name),dmg,false)
			cAT.cHP -= dmg
			if cAT.cHP <= 0:
				cAT.cHP = 0
				cAT.defeat()
				get_node("FOE/"+cAT.name).a.play("defeat")
				print(cAT.name+" is defeated!")
			changeState(BattleStates.NEXTTURN)
	elif currentState == BattleStates.SELECT:
		if !battleFunc.isCurrentTurnEnemy(allies,battlers):
			sel.set_hidden(false)
			if sel.get_pos().distance_to(selDes) > 5: moveObj(sel,selDes,delta)
			if lastState == BattleStates.ALLYCHOICE:
				if playerUsedAbility.get_cost() > cA.cEN:
					print("Not enough energy to use "+playerUsedAbility.name)
					changeState(lastState)
		else:
			#make enemies select a target and an ability
			#cAT = allies[cA.getHighestThreat()]
			print(str(cA.getHighestThreat()))
			if cA.getHighestThreat().size() > 1:
				cAT = allies[0]
			else:
				cAT = allies[cA.getHighestThreat().front()]
			changeState(BattleStates.CALCDAMAGE)
	elif currentState == BattleStates.NEXTTURN:
		if battleFunc.checkForDefeat(foes):
			changeState(BattleStates.WIN)
		elif battleFunc.checkForDefeat(allies):
			changeState(BattleStates.LOSE)
		print(cA.name+" threat values: "+str(cA.threatened))
		toNextTurn -= 1
		if toNextTurn <= 0:
			turn += 1
			toNextTurn = turnLength
			nturn.set_text("TURN: "+str(turn))
		
		battlers.push_back(battlers.front())
		battlers.pop_front()
		cA = battlers.front()
		if cA.defeated:
			print(cA.name+" is defeated. Passing...")
			changeState(BattleStates.PASS)
		get_node("PlayerPanels/Actions/Name").set_text(cA.name+"'s turn!")
		if battleFunc.isCurrentTurnEnemy(allies,battlers):
			changeState(BattleStates.FOECHOICE)
		else:
			changeState(BattleStates.ALLYCHOICE)
	elif currentState == BattleStates.PASS:
		changeState(BattleStates.NEXTTURN)
	elif currentState == BattleStates.LOSE:
		if !setOnce:
			print("*vibeo games voice* YOU LOSE")
			setOnce = true
	elif currentState == BattleStates.WIN:
		if !setOnce:
			print("*video james voice* YOU WIN!")
			setOnce = true

func moveObj(obj,des,deltav=1,spd=500):
	#des takes a vector2
	if obj.get_pos().distance_to(des) > 200:
		spd = spd*5
	if obj.get_pos().distance_to(des) > 50:
		spd = spd*3
	var angle = obj.get_angle_to(des)
	var vel = Vector2(0,0)
	vel.x = spd*sin(angle)
	vel.y = spd*cos(angle)
	
	obj.move(vel*deltav)

func actorClicked(name,click):
	if currentState == BattleStates.SELECT and !battleFunc.isCurrentTurnEnemy(allies,battlers):
		
		if playerUsedAbility.get_ttype() == CONST.SK_TARGET_FOES:
			if battleFunc.isNameEnemy(name,allies) and !foes[get_node("FOE/"+name).numInList].defeated:
				selDes = get_node("FOE/"+name).get_pos()
			
			if click and !foes[get_node("FOE/"+name).numInList].defeated:
				for i in foes:
					if i.name == name:
						cAT = i
						changeState(BattleStates.CALCDAMAGE)
						sel.set_hidden(true)

func timesUp():
	changeState(BattleStates.SELECT)
	get_node("waitTimer").queue_free()
	setOnce = false

func changeState(newState):
	lastState = currentState
	currentState = newState
	setOnce = false

func getLastState():
	return lastState