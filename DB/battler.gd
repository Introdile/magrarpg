extends Node2D

var nidle = "idle"
export(Texture) var idle
export(int) var idle_frames
var i_a = []

var nattack1 = "attack1"
export(Texture) var attack1
export(int) var attack1_frames
var a1_a = []

var ncast1 = "cast1"
export(Texture) var cast1
export(int) var cast1_frames
var c1_a = []

var ndefeat = "defeat"
export(Texture) var defeat
export(int) var defeat_frames

signal actor_clicked(name,click)
var numInList = 0

onready var b = get_node("bSprite")
onready var a = get_node("bSprite/anim")
onready var m = get_node("me")

func _ready():
	randomize()
	prepareme()

func prepareme():
	var i_a = [nidle,idle,idle_frames]
	var a1_a = [nattack1,attack1,attack1_frames]
	var c1_a = [ncast1,cast1,cast1_frames]
	var d_a = [ndefeat,defeat,defeat_frames]
	
	if i_a[1] != null:
		setUpAnimations(i_a)
	if a1_a[1] != null:
		setUpAnimations(a1_a)
	if c1_a[1] != null:
		setUpAnimations(c1_a)
	if  d_a[1] != null:
		setUpAnimations(d_a)
	
	if get_node("bSprite/anim").has_animation("idle"):
		get_node("bSprite/anim").play("idle")
		var iframe = round(rand_range(0,get_node("bSprite").hframes-1))
		get_node("bSprite/anim").seek(iframe,true)
	
	get_node("bSprite/anim").set_speed(6)

func setUpAnimations(aa):
	var nAnim = Animation.new()
	nAnim.set_length(aa[2]+1)
	var x = 0
	#CHANGE TEXTURE
	nAnim.add_track(nAnim.TYPE_VALUE)
	nAnim.track_set_path(x,"../bSprite:texture")
	nAnim.track_insert_key(x,0,aa[1])
	x += 1
	#ADD HFRAMES
	nAnim.add_track(nAnim.TYPE_VALUE)
	nAnim.track_set_path(x,"../bSprite:hframes")
	nAnim.track_insert_key(x,0,aa[2])
	x += 1
	#ADD ANIMATION FRAMES
	nAnim.add_track(nAnim.TYPE_VALUE)
	nAnim.track_set_path(x,"../bSprite:frame")
	for i in range(aa[2]):
		nAnim.track_insert_key(x,i,i)
	if aa[0] == "idle":
		nAnim.set_loop(true)
	get_node("bSprite/anim").add_animation(aa[0],nAnim)

func slideToTarget(des,deltav,spd=250):
	#des = des+get_pos()
	if b.get_pos().distance_to(des) > 100:
		var angle = get_angle_to(des)
		var vel = Vector2(0,0)
		vel.x = spd*sin(angle)
		vel.y = spd*cos(angle)
		
		m.move(vel*deltav)
		get_node("bSprite").set_pos(m.get_pos())

func _on_area_click( viewport, event, shape_idx ):
	if event.is_action_pressed("left_mouse"): 
		emit_signal("actor_clicked",get_name(),true) 
	elif event.type == InputEvent.MOUSE_MOTION: 
		emit_signal("actor_clicked",get_name(),false)
