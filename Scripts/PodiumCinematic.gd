extends Control
class_name PodiumCinematic

var players_sorted = []
var is_victory = false

func start_cinematic(players: Array):
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 4000 # Par dessus TOUT et ABSOLUMENT TOUT
	
	# Je trie par les joueurs ayant un certain type de score
	players_sorted = players.duplicate()
	players_sorted.sort_custom(func(a, b): return a.score > b.score)
	
	# Sachant players_sorted[0] est le gagnant, je check s'il est humain
	is_victory = (players_sorted[0].name == Global.settings.get("PLAYER_NAME", "You"))
	
	# Je fais un fade out au noir
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.0, 0.05)
	bg.modulate.a = 0.0
	add_child(bg)
	
	var t = create_tween()
	t.tween_property(bg, "modulate:a", 1.0, 1.5)
	
	# Je fais le reveal en 4 étapes
	t.tween_callback(func(): _reveal_player(3))

func _reveal_player(rank_idx: int):
	if rank_idx < 0:
		_trigger_final_cinematic()
		return
		
	var p_data = players_sorted[rank_idx]
	
	var pos = Vector2.ZERO
	var col = Color.WHITE
	var scale_factor = 1.0
	var title = ""
	
	match rank_idx:
		3: 
			pos = Vector2(200, 700)
			col = Color(0.4, 0.4, 0.4)
			scale_factor = 0.7
			title = "4TH PLACE"
		2: 
			pos = Vector2(1450, 600)
			col = Color(0.8, 0.5, 0.2)
			scale_factor = 0.9
			title = "BRONZE"
		1:
			pos = Vector2(500, 500)
			col = Color(0.8, 0.8, 0.9)
			scale_factor = 1.1
			title = "SILVER"
		0:
			pos = Vector2(960 - 200, 250)
			col = Color("FFD700")
			scale_factor = 1.6
			title = "CHAMPION"
			
	var p_node = _create_podium_card(p_data.name, p_data.score, title, col, scale_factor)
	p_node.position = pos
	p_node.scale = Vector2.ZERO
	add_child(p_node)
	
	var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var delay = 0.0
	
	if rank_idx == 0: 
		# Gros delai du suspense
		t.tween_interval(2.5) 
		delay = 2.5
	
	t.tween_property(p_node, "scale", Vector2.ONE, 0.6).set_delay(delay)
	
	if rank_idx == 0:
		# Explosion du gagnant
		t.chain().tween_callback(func(): _spawn_winner_particles(pos + Vector2(200, 100), col))
		
	var next_wait = 1.2 if rank_idx != 0 else 3.5
	t.chain().tween_interval(next_wait)
	t.chain().tween_callback(func(): _reveal_player(rank_idx - 1))

func _create_podium_card(p_name: String, score: int, rank_title: String, col: Color, s_factor: float) -> Control:
	var con = Control.new()
	con.custom_minimum_size = Vector2(400, 200)
	con.pivot_offset = Vector2(200, 100)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	sb.set_corner_radius_all(15)
	sb.set_border_width_all(5)
	sb.border_color = col
	sb.shadow_color = Color(col.r, col.g, col.b, 0.3)
	sb.shadow_size = int(20 * s_factor)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", sb)
	con.add_child(panel)
	
	var font = SystemFont.new()
	font.font_names = PackedStringArray(["Arial Black", "Impact", "Sans-Serif"])
	font.font_weight = 900
	
	var lbl_title = Label.new()
	lbl_title.text = rank_title
	lbl_title.add_theme_font_override("font", font)
	lbl_title.add_theme_font_size_override("font_size", 28)
	lbl_title.add_theme_color_override("font_color", col)
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.position = Vector2(0, -40)
	lbl_title.custom_minimum_size = Vector2(400, 40)
	con.add_child(lbl_title)
	
	var lbl_name = Label.new()
	lbl_name.text = p_name
	lbl_name.add_theme_font_override("font", font)
	lbl_name.add_theme_font_size_override("font_size", 42)
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.position = Vector2(0, 40)
	lbl_name.custom_minimum_size = Vector2(400, 60)
	con.add_child(lbl_name)
	
	var lbl_score = Label.new()
	lbl_score.text = str(score) + " Pts"
	lbl_score.add_theme_font_override("font", font)
	lbl_score.add_theme_font_size_override("font_size", 56)
	lbl_score.add_theme_color_override("font_color", col)
	lbl_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_score.position = Vector2(0, 100)
	lbl_score.custom_minimum_size = Vector2(400, 60)
	con.add_child(lbl_score)
	
	return con

func _spawn_winner_particles(pos: Vector2, col: Color):
	var parts = CPUParticles2D.new()
	parts.position = pos
	parts.amount = 150
	parts.lifetime = 2.0
	parts.one_shot = true
	parts.explosiveness = 0.9
	parts.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	parts.emission_sphere_radius = 50.0
	parts.spread = 180.0
	parts.initial_velocity_min = 200.0
	parts.initial_velocity_max = 800.0
	parts.scale_amount_min = 5.0
	parts.scale_amount_max = 15.0
	parts.color = col
	add_child(parts)
	parts.emitting = true

func _trigger_final_cinematic():
	var wipe = ColorRect.new()
	wipe.set_anchors_preset(Control.PRESET_FULL_RECT)
	wipe.color = Color.BLACK
	wipe.modulate.a = 0.0
	wipe.z_index = 100
	add_child(wipe)
	
	var t = create_tween()
	t.tween_property(wipe, "modulate:a", 1.0, 1.0)
	
	t.tween_callback(func():
		var font: Font
		if ResourceLoader.exists("res://Rockybilly.ttf"): font = load("res://Rockybilly.ttf")
		else:
			font = SystemFont.new()
			font.font_names = PackedStringArray(["Georgia", "Times New Roman", "Serif"])
			font.font_weight = 900
			font.font_italic = true
		
		var final_text = Label.new()
		final_text.add_theme_font_override("font", font)
		final_text.add_theme_font_size_override("font_size", 180)
		final_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		final_text.custom_minimum_size = Vector2(1920, 300)
		final_text.pivot_offset = Vector2(1920/2.0, 150)
		final_text.z_index = 200
		
		if is_victory:
			# Écran final victoire
			final_text.text = "V I C T O R Y"
			final_text.add_theme_color_override("font_color", Color("FFD700"))
			final_text.position = Vector2(0, 600) 
			add_child(final_text)
			
			var ct = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			ct.tween_property(final_text, "position:y", 350, 4.0) 
			ct.tween_property(final_text, "scale", Vector2(1.1, 1.1), 4.0)
			
			# Particules
			var petals = CPUParticles2D.new()
			petals.position = Vector2(1920/2.0, -100)
			petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			petals.emission_rect_extents = Vector2(960, 10)
			petals.amount = 200
			petals.lifetime = 8.0
			petals.gravity = Vector2(0, 50)
			petals.initial_velocity_min = 10.0
			petals.initial_velocity_max = 50.0
			petals.scale_amount_min = 5.0
			petals.scale_amount_max = 12.0
			petals.color = Color("FFD700")
			add_child(petals)
			
		else:
			# Écran final défaite
			final_text.text = "D E F E A T"
			final_text.add_theme_color_override("font_color", Color(0.6, 0.0, 0.0))
			final_text.position = Vector2(0, 100)
			final_text.scale = Vector2(3.0, 3.0)
			final_text.modulate.a = 0.0
			add_child(final_text)
			
			var ct = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			ct.tween_property(final_text, "position:y", 350, 1.5) 
			ct.tween_property(final_text, "scale", Vector2(1.0, 1.0), 1.5)
			ct.tween_property(final_text, "modulate:a", 1.0, 1.5)
			ct.chain().tween_callback(func():
				var shake = create_tween()
				for i in range(10): shake.tween_property(final_text, "position", Vector2(randf_range(-30,30), 350 + randf_range(-30,30)), 0.03)
				shake.tween_property(final_text, "position", Vector2(0, 350), 0.05)
				
				# Particules
				var ash = CPUParticles2D.new()
				ash.position = Vector2(1920/2.0, -100)
				ash.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
				ash.emission_rect_extents = Vector2(960, 10)
				ash.amount = 300
				ash.lifetime = 8.0
				ash.gravity = Vector2(0, 80)
				ash.scale_amount_min = 2.0
				ash.scale_amount_max = 8.0
				ash.color = Color(0.2, 0.2, 0.2)
				add_child(ash)
			)
			
		# J'attends et je retourne au menu principal
		var exit_t = create_tween()
		exit_t.tween_interval(6.0)
		exit_t.tween_property(wipe, "modulate:a", 1.0, 1.0) 
		exit_t.tween_property(final_text, "modulate:a", 0.0, 1.0)
		exit_t.tween_callback(func():
			if Global.has_method("goto_scene"): Global.goto_scene("res://Scenes/MainMenu.tscn")
			else: get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
)			
)
