extends Area2D

export var sceneToMove = ""

func _scene_change( body ):
	if body.get_name() == "Player":
		get_node("/root/World").queue_free()
		get_node("/root").add_child(load(sceneToMove).instance())