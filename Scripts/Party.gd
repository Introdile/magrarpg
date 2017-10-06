extends CanvasLayer

var partyHolder
var partySelect
var badgeList

#press once
var up = false
var down = false
var right = false
var left = false
var interact = false
var menu = false

var updateMe = true

var currentItem = 0

func _ready():
	var partyItem = load("res://Scenes/PartyItem.xml")
	
	partySelect = get_node("select")
	partyHolder = get_node("partyItems")
	#partyHolder.set_pos(Vector2(Globals.get("display/width")/2,64))
	badgeList = get_node("activeBadges")
	
	update_info(0,true)
	
	for i in range(GAME_DATA.party.size()):
		var set = false
		for act in partyHolder.get_children():
			if act.get_name().find("_active") != -1 and set == false:
				if act.get_node("charPortrait").get_frame() == 0:
					act.get_node("charPortrait").set_frame(GAME_DATA.party[i].portrait)
					set = true
	
	for i in range(GAME_DATA.inactive.size()):
		var set = false
		for inact in partyHolder.get_children():
			if inact.get_name().find("inactive") != -1 and set == false:
				if inact.get_node("charPortrait").get_frame() == 0:
					inact.get_node("charPortrait").set_frame(GAME_DATA.inactive[i].portrait)
					set = true
	
	partySelect.set_pos(partyHolder.get_pos()+partyHolder.get_child(currentItem).get_pos())
	#sets Magra to the active party member
	#badgeList.get_node(str(1)).set_pos(partyHolder.get_pos()+partyHolder.get_child(0).get_pos())
	
	set_process_unhandled_key_input(true)
	set_process(true)

func _unhandled_key_input(key_event):
	if key_event.is_action_pressed("ui_menu"):
		menu = true
	elif key_event.is_action_released("ui_menu"):
		menu = false
	
	if key_event.is_action_pressed("ui_up"):
		up = true
	elif key_event.is_action_released("ui_up"):
		up = false
	
	if key_event.is_action_pressed("ui_down"):
		down = true
	elif key_event.is_action_released("ui_down"):
		down = false
	
	if key_event.is_action_pressed("ui_left"):
		left = true
	elif key_event.is_action_released("ui_left"):
		left = false
	
	if key_event.is_action_pressed("ui_right"):
		right = true
	elif key_event.is_action_released("ui_right"):
		right = false
		
	if key_event.is_action_pressed("ui_interact"):
		interact = true
	elif key_event.is_action_released("ui_interact"):
		interact = false

func _process(delta):
	if up and (currentItem-4) >= 0:
		currentItem -= 4
		updateMe = true
	elif down and (currentItem+4) <= 11:
		currentItem += 4
		updateMe = true
	elif right and currentItem+1 <= 11:
		currentItem += 1
		updateMe = true
	elif left and currentItem-1 >= 0:
		currentItem -= 1
		updateMe = true
	
	if updateMe:
		if currentItem < 4:
			update_info(currentItem, true)
		elif currentItem >= 4:
			update_info(currentItem, false)
		updateMe = false
	
	if interact:
		move_party_member(currentItem)
		update_portraits()
	
	if menu:
		get_node("/root/World/TileMap/Player/playerCam/menu").open = true
		queue_free()
	
	up = false
	down = false
	right = false
	left = false
	interact = false
	menu = false

func update_info(num, act):
	#act should be a bool, if true, it'll pull from the active party list
	#if false, it will pull from the inactive party list
	if act:
		if(num < GAME_DATA.party.size()):
			#name and class
			get_node("partyInfo/Name").set_text(GAME_DATA.party[num].name)
			get_node("partyInfo/Class").set_text(GAME_DATA.party[num].spec)
			
			#other stats
			get_node("partyInfo/Health").set_text(str(GAME_DATA.party[num].HP))
			get_node("partyInfo/Energy").set_text(str(GAME_DATA.party[num].EN))
			get_node("partyInfo/Might").set_text(str(GAME_DATA.party[num].MG))
			get_node("partyInfo/Crit").set_text(str(GAME_DATA.party[num].AM))
			get_node("partyInfo/Potency").set_text(str(GAME_DATA.party[num].PT))
			get_node("partyInfo/Echo").set_text(str(GAME_DATA.party[num].EC))
			get_node("partyInfo/Dodge").set_text(str(GAME_DATA.party[num].DG))
			get_node("partyInfo/Speed").set_text(str(GAME_DATA.party[num].SD))
			
			#fluff
			get_node("partyImage").set_frame(GAME_DATA.party[num].portrait)
			get_node("partyInfo/Desc").set_text(GAME_DATA.party[num].shortDesc)
	elif !act:
		var inum = num-4
		if inum < GAME_DATA.inactive.size():
			#name and class
			get_node("partyInfo/Name").set_text(GAME_DATA.inactive[inum].name)
			get_node("partyInfo/Class").set_text(GAME_DATA.inactive[inum].spec)
			
			#other stats
			get_node("partyInfo/Health").set_text(str(GAME_DATA.inactive[inum].HP))
			get_node("partyInfo/Energy").set_text(str(GAME_DATA.inactive[inum].EN))
			get_node("partyInfo/Might").set_text(str(GAME_DATA.inactive[inum].MG))
			get_node("partyInfo/Crit").set_text(str(GAME_DATA.inactive[inum].AM))
			get_node("partyInfo/Potency").set_text(str(GAME_DATA.inactive[inum].PT))
			get_node("partyInfo/Echo").set_text(str(GAME_DATA.inactive[inum].EC))
			get_node("partyInfo/Dodge").set_text(str(GAME_DATA.inactive[inum].DG))
			get_node("partyInfo/Speed").set_text(str(GAME_DATA.inactive[inum].SD))
			
			#flavor
			get_node("partyImage").set_frame(GAME_DATA.inactive[inum].portrait)
			get_node("partyInfo/Desc").set_text(GAME_DATA.inactive[inum].shortDesc)
			#if partyHolder.get_child(num) != null:
			#	partySelect.set_pos(partyHolder.get_pos()+partyHolder.get_child(num).get_pos())
	partySelect.set_pos(partyHolder.get_pos()+partyHolder.get_child(num).get_pos())

func move_party_member(num):
	#first it checks whether the selection is on the active party or the inactive party
	if num < 4:
		if num < GAME_DATA.party.size():
			#if active, it checks if the selection is on an actual party member
			#it also checks if the active party is above the minimum size (1)
			if GAME_DATA.party.size() <= 1:
				print("Active party must have at least 1 member!")
			else:
				print("Removing "+ GAME_DATA.party[num].name + " from the party!")
				GAME_DATA.inactive.push_back(GAME_DATA.party[num])
				GAME_DATA.party.remove(num)
	if num >= 4:
		var inum = num-4
		print(str(inum))
		if inum < GAME_DATA.inactive.size():
			if GAME_DATA.party.size() < 4:
				print("Adding "+ GAME_DATA.inactive[inum].name + " to the party!")
				GAME_DATA.party.push_back(GAME_DATA.inactive[inum])
				GAME_DATA.inactive.remove(inum)
			else:
				print("Party is already full!")

func update_portraits():
	for i in get_node("partyItems").get_children():
		i.get_node("charPortrait").set_frame(0)
	for i in range(GAME_DATA.party.size()):
		var set = false
		for act in partyHolder.get_children():
			if act.get_name().find("_active") != -1 and set == false:
				if act.get_node("charPortrait").get_frame() == 0:
					act.get_node("charPortrait").set_frame(GAME_DATA.party[i].portrait)
					set = true
	
	for i in range(GAME_DATA.inactive.size()):
		var set = false
		for inact in partyHolder.get_children():
			if inact.get_name().find("inactive") != -1 and set == false:
				if inact.get_node("charPortrait").get_frame() == 0:
					inact.get_node("charPortrait").set_frame(GAME_DATA.inactive[i].portrait)
					set = true

