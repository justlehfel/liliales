extends Node2D
class_name TrickPopup

signal popup_finished 

var shake_intensity: float = 0.0
var base_pos: Vector2

func play_anim(winner_name: String, points: int, blaster_name: String):
	z_index = 1000
	base_pos = Vector2(1920.0 / 2.0, 1080.0 / 2.0)
	position = base_pos
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.position = -Vector2(1920, 1080)
	bg.size = Vector2(3840, 2160)
	add_child(bg)
	
	var font = SystemFont.new()
	font.font_names = PackedStringArray(["Trebuchet MS", "Verdana", "Arial Black", "Sans-Serif"])
	font.font_weight = 800
	
	var title = Label.new()
	var score = Label.new()
	
	for lbl in [title, score]:
		lbl.add_theme_font_override("font", font)
		lbl.add_theme_constant_override("outline_size", 12)
		lbl.add_theme_color_override("font_outline_color", Color(0.1, 0.0, 0.0))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(lbl)
		
	title.position = Vector2(-600, -100)
	title.custom_minimum_size = Vector2(1200, 100)
	title.add_theme_font_size_override("font_size", 52)
	
	score.position = Vector2(-600, -20)
	score.custom_minimum_size = Vector2(1200, 150)
	score.add_theme_font_size_override("font_size", 90)
	
	var t = create_tween()
	t.tween_property(bg, "color:a", 0.65, 0.4) 
	
	if points >= 0:
		title.text = "A Splendid Victory for %s" % winner_name
		title.add_theme_color_override("font_color", Color("E0E0E0"))
		score.text = "+%d Gold" % points
		score.add_theme_color_override("font_color", Color("FFD700"))
		
		scale = Vector2(0.8, 0.8)
		modulate.a = 0.0
		
		t.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(self, "modulate:a", 1.0, 0.5)
		t.tween_interval(1.6)
		t.tween_property(self, "position:y", position.y - 60, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		t.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
		t.parallel().tween_property(bg, "color:a", 0.0, 0.5)
		
	else:
		if blaster_name == winner_name:
			if winner_name.to_lower() == "you":
				title.text = "You succumbed to your own poison..."
			else:
				title.text = "%s succumbed to their own poison..." % winner_name
		else:
			title.text = "%s was betrayed by %s" % [winner_name, blaster_name]
			
		title.add_theme_color_override("font_color", Color("FF9999"))
		score.text = "%d Points" % points
		score.add_theme_color_override("font_color", Color("FF2222")) 
		
		scale = Vector2(1.15, 1.15)
		modulate.a = 0.0
		
		t.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(self, "modulate:a", 1.0, 0.4)
		
		t.tween_callback(func(): shake_intensity = 15.0) 
		t.tween_interval(2.0)
		
		t.tween_property(self, "modulate:a", 0.0, 0.6)
		t.parallel().tween_property(bg, "color:a", 0.0, 0.6)

	t.tween_callback(func():
		popup_finished.emit() 
		queue_free()
	)

func _process(delta):
	if shake_intensity > 0:
		position = base_pos + Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = move_toward(shake_intensity, 0.0, 40.0 * delta)
