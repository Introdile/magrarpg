extends CanvasLayer

var invHolder

#press once
var up = false
var down = false
var menu = false
var currentItem = 0

func update_info():
	get_node("Name").set_text(global.inv[currentItem].Name)
	get_node("Desc").set_text(global.inv[currentItem].Desc)
	get_node("invImage").set_frame(global.inv[currentItem].Tile)

func _ready():
	var invItem = load("res://Scenes/PartyItem.xml")
	
	invHolder = get_node("invItems")
	var x = 0
	var y = 0
	
	get_node("Name").set_text(global.inv[0].Name)
	get_node("Desc").set_text(global.inv[0].Desc)
		
	for i in global.inv:
		var node = invItem.instance()
		node.set_pos(Vector2(x,y))
		node.get_node("Name").set_text(i.Name)
		invHolder.add_child(node)
		y += 42+10
	
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

func _process(delta):
	if up && currentItem < global.inv.size()-1:
		invHolder.set_pos(invHolder.get_pos() + Vector2(0,-52))
		currentItem += 1
		update_info()
	
	elif down && currentItem > 0:
		invHolder.set_pos(invHolder.get_pos() + Vector2(0,52))
		currentItem -= 1
		update_info()
	
	if menu:
		get_node("/root/World/TileMap/Player/playerCam/menu").open = true
		queue_free()
	
	up = false
	down = false
	menu = false