extends TextureButton

export(String) var buttonName
export(String,MULTILINE) var buttonDesc
export(int) var buttonFrame

func _ready():
	get_node("Sprite").set_frame(buttonFrame)