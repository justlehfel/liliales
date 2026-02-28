extends ColorRect

func _ready():
	# Je force le full screen du background de marde
	# Parce que Godot marche en visuel et chu pas un dude de visuel
	# Vive les scripts
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	
	# Si le shader marche pas, je mets une couleur au moins
	color = Color(0.2, 0.05, 0.05) 
	
	# Je check deux fois pour voir qu'il soit bien en arrière de toute
	z_index = -100
