extends KinematicBody2D

export var MOTION_SPEED = 140
const IDLE_SPEED = 10

var canMove = true
var interact = false
var menu = false

var RayNode
var PlayerAnimNode
var sprite
var world

var anim = ""
var animNew = ""

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	world = get_world_2d().get_direct_space_state()
	
	RayNode = get_node("RayCast2D")
	PlayerAnimNode = get_node("visible/AnimationPlayer")
	sprite = get_node("visible")

func _input(event):
	if event.is_action_pressed("ui_interact"):
		interact = true
	elif event.is_action_released("ui_interact"):
		interact = false
		
	if event.is_action_pressed("ui_menu"):
		menu = true
	elif event.is_action_released("ui_menu"):
		menu = false

func _fixed_process(delta):
	var motion = Vector2()
	
	if(canMove):
		#motion
		if (Input.is_action_pressed("ui_up")):
			motion += Vector2(0, -1)
			RayNode.set_rotd(180)
		
		if (Input.is_action_pressed("ui_down")):
			motion += Vector2(0, 1)
			RayNode.set_rotd(0)
		
		if (Input.is_action_pressed("ui_left")):
			motion += Vector2(-1, 0)
			RayNode.set_rotd(-90)
		
		if (Input.is_action_pressed("ui_right")):
			motion += Vector2(1, 0)
			RayNode.set_rotd(90)
		
		motion = motion.normalized()*MOTION_SPEED*delta
		move(motion)
	
	#interaction
	if interact:
		interact(RayNode.get_collider())
	
	#menu
	if menu and canMove:
		get_node("playerCam/menu")._open_menu()
	
	#Animations

	if (RayNode.get_rotd() == 180):
		if (motion.length() > IDLE_SPEED*0.09):
			anim = "walk_u"
		else:
			anim = "idle_u"
		
	if (RayNode.get_rotd() == -90):
		if (motion.length() > IDLE_SPEED*0.09):
			anim = "walk_l"
		else:
			anim = "idle_l"
		
	if (RayNode.get_rotd() == 90):
		if (motion.length() > IDLE_SPEED*0.09):
			anim = "walk_r"
		else:
			anim = "idle_r"
		
	if (RayNode.get_rotd() == 0):
		if (motion.length() > IDLE_SPEED*0.09):
			anim = "walk_d"
		else:
			anim = "idle_d"
	
	interact = false
	menu = false
	
	if anim != animNew:
		animNew = anim
		PlayerAnimNode.play(anim)
	

func interact(result):
	if(result != null && result.has_node("Interact")):
		get_node("playerCam/dialogueBox").set_hidden(false)
		get_node("playerCam/dialogueBox")._print_dialogue(result.get_parent().text)
		