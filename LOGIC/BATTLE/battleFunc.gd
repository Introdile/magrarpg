extends Node

#onready var battle = preload("res://LOGIC/BATTLE/battlefield.gd")

static func prepareBattlers(n,p,l,f=false):
	#n takes the node to attach battlers to
	#p takes the array that contains the list of combatants
	#l takes true if the battlers are on the left or false if they're on the right
	#f takes true if the battlers it is setting up are enemies
	var bat = preload("res://DB/battler.tscn")
	var set = 0
	
	if l:
		var x = 192
		var y = 96
		
		for c in p:
			var damn = bat.instance()
			
			if !f: damn.set_name(c.name)
			else: damn.set_name(c.name+str(set))
			damn.numInList = set
			
			damn.set_pos(Vector2(x,y))
			damn.idle = c.battleSprite
			if c.name == "Magra":
				damn.idle_frames = 8
			else:
				damn.idle_frames = 4
			damn.prepareme()
			n.add_child(damn)
			x += 48
			y += 64
			set += 1
	else:
		var x = Globals.get("display/width")-192
		var y = 96
		
		for c in p:
			var damn = bat.instance()
			
			if !f: damn.set_name(c.name)
			else: damn.set_name(c.name+str(set))
			damn.numInList = set
			
			damn.get_node("bSprite").set_flip_h(true)
			damn.set_pos(Vector2(x,y))
			damn.idle = c.battleSprite
			damn.idle_frames = 4
			damn.prepareme()
			n.add_child(damn)
			x -= 48
			y += 64
			set += 1

static func listPlayerMoves(p,c):
	#p takes the panel node
	#c takes the current character
	var y = 16
	
	if p.get_child_count() != 0:
		for i in p.get_children():
			i.queue_free()
	
	#Create Pass turn button
	var delay = Button.new()
	delay.set_pos(Vector2(16,y))
	delay.set_text("Pass")
	delay.set_name("Pass")
	p.add_child(delay)
	y += 32
	
	#Create other skill buttons
	for i in c.skills:
		var butt = Button.new()
		butt.set_pos(Vector2(16,y))
		butt.set_text(i.get_name())
		butt.set_name(i.get_name())
		p.add_child(butt)
		y += 32

static func isSpeedGreater(a,b):
	return a._stat[7] > b._stat[7]

static func isCurrentTurnEnemy(a,b):
	#a takes the ally character list
	#b takes the current battler list
	for i in a:
		if i == b.front():
			return false
	return true

static func isNameEnemy(n,a):
	#n takes a name string
	#a takes the ally character list
	for i in a:
		if i.name == n:
			return false
	return true

static func setUpBars(p,a):
	#p takes the panel to attach to
	#a takes the list of allies
	var y = 16
	for i in a:
		#sets a holder for ease of access
		var holder = Node2D.new()
		holder.set_name(i.name+"info")
		p.add_child(holder)
		holder.set_pos(Vector2(0,0))
		#make a label for the character's name
		var name = Label.new()
		name.set_text(i.name)
		name.set_pos(Vector2(16,y))
		#make a label for HP:
		var hpL = Label.new()
		hpL.set_text("HP:")
		hpL.set_pos(Vector2(16,y+18))
		#make an HP bar for the character
		var hp = ProgressBar.new()
		hp.set_name("hp")
		hp.set_pos(Vector2(42,y+14))
		hp.set_size(Vector2(128,20))
		hp.set_max(i._stat[0])
		hp.set_value(i.stat[0])
		hp.set_percent_visible(false)
		#make a label for EN:
		var enL = Label.new()
		enL.set_text("EN:")
		enL.set_pos(Vector2(186,y+18))
		#make an EN bar for the character
		var en = ProgressBar.new()
		en.set_name("en")
		en.set_pos(Vector2(186+24,y+14))
		en.set_size(Vector2(128,20))
		en.set_max(i._stat[1])
		en.set_value(i.stat[1])
		en.set_percent_visible(false)
		y += 48
		holder.add_child(name)
		holder.add_child(hp)
		holder.add_child(hpL)
		holder.add_child(en)
		holder.add_child(enL)

static func updateBars(p,c,b):
	#p takes the panel node
	#c takes the character's bar to update (ideally should be in party)
	#b takes the bar to update (hp or en)
	if b == "hp":
		var hp = p.get_node("Info/"+c.name+"info/hp")
		if hp.get_value() < c.cHP:
			while hp.get_value() < c.cHP:
				hp.set_value(hp.get_value()+1)
		elif hp.get_value() > c.cHP:
			while hp.get_value() > c.cHP:
				hp.set_value(hp.get_value()-1)
	elif b == "en":
		var en = p.get_node("Info/"+c.name+"info/en")
		if en.get_value() < c.cEN:
			while en.get_value() < c.cEN:
				en.set_value(en.get_value()+1)
		elif en.get_value() > c.cEN:
			while en.get_value() > c.cEN:
				en.set_value(en.get_value()-1)

static func calculateDamage(a,s,t,e=true):
	#a takes the current character
	#s takes the skill used
	#t takes the target character
	#e takes whether or not the attack can echo
	var bDam = preload("res://LOGIC/BATTLE/battleDam.tscn")
	var dam
	var damMod = s.get_power()*0.1
	var damMin = a.minAtk*damMod
	var damMax = a.maxAtk*damMod
	var threat = s.get_threat()
	dam = round(rand_range(damMin,damMax))
	
	
	if s.get_type() == 0: #melee
		var armor = t.AR
		#roll the critical strike chance, which will be compared against aim
		
		#check crit chance, apply extra damage
		if randChance(a.get_crit_chance()):
			print("Critical strike!")
			#TODO: use weapon's critical strike multiplier instead
			dam = dam*1.5
			threat = threat*1.5
		
		if randChance(t.get_dodge_chance()):
			print("Dodge!")
			dam = dam*0.75
			threat = threat*0.5
		
		if randChance(t.get_parry_chance()):
			print("Parry!")
			#TODO: add in parrying
			#parrying will have a much lower chance than dodge
			#it completely stops an attack and stuns the attacker
		
		#dodge chance + parry
	elif s.get_type() == 1: #ranged
		#RANGE ATTACKS:
		#RANGED ATTACKS CAN CRITICALLY STRIKE AND BE DODGED
		#RANGED MOVES TEND TO HAVE A HIGHER CRIT CHANCE THAN MELEE MOVES
		#RANGED MOVES CAN BE MORE EASILY DODGE, HOWEVER
		var armor = t.AR
		
		#check crit chance, apply extra damage
		if randChance(a.get_crit_chance()):
			print("Critical strike!")
			#TODO: use weapon's critical strike multiplier instead
			dam = dam*1.5
			threat = threat*1.5
		
		if randChance(t.get_dodge_chance()):
			print("Dodged!")
			dam = dam*0.75
		#dodge chance, no parry
	elif s.get_type() == 2: #magic
		#MAGIC ATTACKS:
		#MAGIC DAMAGE IS REDUCED BY A CHARACTER'S WARD STAT
		#MAGIC ATTACKS CANNOT BE BLOCKED OR PARRIED BUT THEY CAN BE REFLECTED
		var ward = t.WD
		
		var mmnDam = (a.PT*0.75)*damMod
		var mmxDam = (a.PT*1.25)*damMod
		
		if e:
			#if randChance(a.get_echo_chance()):
			#	print("Echo!")
			#	calculateDamage(a,s,t,false)
			dam = round(rand_range(mmnDam,mmxDam))
		elif !e:
			dam = round(rand_range(mmnDam,mmxDam)) * 0.5
			threat = threat*0.1
		#ward chance + reflect
	
	print(a.name+"'s "+s.get_name()+" dealt "+str(round(dam))+" damage to "+t.name)
	
	t.threaten(GD.party.find(a),threat)
	a.cEN = a.cEN-s.get_cost()
	return round(dam)

static func randChance(target):
	#target should be a number between 0 and 1
	var ch = rand_range(0,1)
	if ch < target:
		return true
	return false

static func checkForDefeat(l):
	#l takes an ally or enemy array
	var d = 0
	var dM = l.size()
	for i in l:
		if i.defeated == true:
			d += 1
	if d >= dM:
		return true
	return false

static func spawnText(w,d,c):
	#w takes an object to spawn it on
	#d takes an amount of damage to display
	#c takes whether or not damage was a crit
	var dTxt = preload("res://LOGIC/BATTLE/battleDam.tscn").instance()
	dTxt.set_text(str(d))
	dTxt.get_node("AnimationPlayer").play("float")
	w.add_child(dTxt)
	dTxt.set_pos(w.get_pos()-Vector2(16,48))