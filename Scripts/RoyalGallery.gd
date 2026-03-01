extends Control

var grid: GridContainer
var progress_bar: ProgressBar
var back_btn: Button
var counter_label: Label
var roadmap_area: Control
var title: Label
var bg: ColorRect
var scroll_container: ScrollContainer

var gallery_panels: Array = []
var target_unlocked: int = 0
var current_displayed_count: float = 0.0

func _ready():
	modulate.a = 0.0 
	
	_build_ui_hierarchy()
	_setup_back_button()
	_populate_gallery()
	_update_roadmap()
	
	_play_enter_animation()

func _process(delta):
	if current_displayed_count < target_unlocked:
		current_displayed_count = move_toward(current_displayed_count, target_unlocked, delta * 15.0)
		var am = get_node_or_null("/root/AchievementManager")
		var total = am.DATABASE.size() if am else 0
		counter_label.text = "[ %d / %d Unlocked ]" % [int(current_displayed_count), total]
	
	# Le counter détient une belle animation
	var t_val = Time.get_ticks_msec() / 1000.0
	var pulse = (sin(t_val * 3.5) + 1.0) * 0.5
	counter_label.scale = Vector2(1.0, 1.0) + Vector2(0.04, 0.04) * pulse
	counter_label.modulate = Color(1.0, 1.0, 1.0).lerp(Color("FFD700"), pulse * 0.3)

func _build_ui_hierarchy():
	# --- Background du nouveau menu ---
	bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sm_bg = ShaderMaterial.new()
	var sh_bg = Shader.new()
	sh_bg.code = """
	shader_type canvas_item;

	uniform vec4 crimson_base : source_color = vec4(0.06, 0.0, 0.01, 1.0); 
	uniform vec4 crimson_core : source_color = vec4(0.2, 0.02, 0.03, 1.0); 
	uniform vec4 engraving_gold : source_color = vec4(0.95, 0.75, 0.2, 1.0); 
	uniform vec4 highlight_gold : source_color = vec4(1.0, 0.95, 0.7, 1.0); 
	uniform float pattern_scale = 5.5; 

	float dense_royal_pattern(vec2 uv) {
		vec2 warp = vec2(sin(uv.y * 2.0 + TIME * 0.4), cos(uv.x * 2.0 + TIME * 0.3)) * 0.04;
		vec2 p = uv * 3.14159 * 2.0 + warp;
		float c1 = sin(p.x * 2.0) * cos(p.y * 2.0);
		float c2 = sin(p.x + p.y) * 1.5;
		float c3 = cos(p.x * 2.5 - p.y * 2.5) * 0.8;
		float val = c1 + c2 + c3;
		float outline = abs(val);
		float ink = smoothstep(0.18, 0.02, outline); 
		float pools = smoothstep(1.8, 2.2, abs(val));
		return clamp(ink + pools * 0.5, 0.0, 1.0);
	}

	void fragment() {
		vec2 uv = UV;
		uv.x *= 1.777; 
		vec2 center_uv = UV - vec2(0.5);
		float dist = length(center_uv);
		float pulse = (sin(TIME * 1.2) + 1.0) * 0.5; 
		
		vec3 bg = mix(crimson_core.rgb * (0.7 + pulse * 0.2), crimson_base.rgb, dist * 1.4);
		vec2 p = uv * pattern_scale;
		float ink_mask = dense_royal_pattern(p) * 0.75; 
		
		float wave1 = sin(uv.x * 6.0 - uv.y * 3.0 + TIME * 2.0);
		float wave2 = cos(uv.x * -2.5 - uv.y * 5.0 + TIME * 1.5);
		float wave3 = sin(uv.x * 15.0 + uv.y * 15.0 - TIME * 4.0); 
		
		float glisten = max(0.0, (wave1 + wave2) * 0.5); 
		glisten = pow(glisten, 3.0); 
		float sparkle = max(0.0, wave3) * pow(glisten, 4.0); 
		
		vec3 gold_color = mix(engraving_gold.rgb, highlight_gold.rgb, glisten);
		gold_color += highlight_gold.rgb * sparkle * 2.5; 
		
		float ink_depth = smoothstep(0.0, 1.0, ink_mask) + (glisten * 0.6);
		vec3 final_ink = gold_color * ink_depth;

		bg += engraving_gold.rgb * ink_mask * 0.08 * (1.0 + glisten);
		vec3 final_color = mix(bg, final_ink, ink_mask);
		
		final_color *= (1.15 - dist * 0.9);
		COLOR = vec4(final_color, 1.0);
	}
	"""
	sm_bg.shader = sh_bg
	bg.material = sm_bg
	add_child(bg)

	# --- 2. Layout ---
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 130) 
	margin.add_theme_constant_override("margin_bottom", 60)
	margin.add_theme_constant_override("margin_left", 60) 
	margin.add_theme_constant_override("margin_right", 80)
	add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 100) 
	margin.add_child(hbox)

	# --- 3. Flèche de progression ---
	roadmap_area = Control.new()
	roadmap_area.custom_minimum_size = Vector2(400, 0)
	roadmap_area.pivot_offset = Vector2(200, 400)
	hbox.add_child(roadmap_area)

	var title_font: Font
	if ResourceLoader.exists("res://Assets/Fonts/Rockybilly.ttf"): title_font = load("res://Assets/Fonts/Rockybilly.ttf")
	elif ResourceLoader.exists("res://Rockybilly.ttf"): title_font = load("res://Rockybilly.ttf")
	else:
		title_font = SystemFont.new()
		title_font.font_names = PackedStringArray(["Impact", "Arial Black"])

	title = Label.new()
	title.text = "Royal Gallery" 
	title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", 54) 
	title.add_theme_color_override("font_color", Color(0.8, 0.6, 0.1)) 
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_outline_color", Color(0.1, 0.0, 0.02))
	title.add_theme_constant_override("shadow_offset_y", 6)
	title.add_theme_color_override("font_shadow_color", Color(0,0,0, 0.8))
	title.position = Vector2(-20, -40)
	
	var sm_font = ShaderMaterial.new()
	var sh_font = Shader.new()
	sh_font.code = """
	shader_type canvas_item;
	void fragment() {
		vec4 font_mask = texture(TEXTURE, UV);
		float sweep = pow(sin(UV.x * 4.0 - UV.y * 2.0 - TIME * 1.5) * 0.5 + 0.5, 5.0);
		float pulse = (sin(TIME * 2.0) + 1.0) * 0.5;
		vec3 glow = vec3(0.5, 0.2, 0.0) * pulse + vec3(0.9, 0.7, 0.1) * sweep;
		COLOR = vec4(COLOR.rgb + glow, COLOR.a * font_mask.a);
	}
	"""
	sm_font.shader = sh_font
	title.material = sm_font
	roadmap_area.add_child(title)
	
	var float_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(title, "position:y", -30.0, 2.0)
	float_tween.tween_property(title, "position:y", -40.0, 2.0)
	
	counter_label = Label.new()
	counter_label.position = Vector2(100, 240)
	counter_label.pivot_offset = Vector2(100, 20)
	counter_label.add_theme_font_size_override("font_size", 34)
	counter_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	roadmap_area.add_child(counter_label)

	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(80, 560) 
	progress_bar.position = Vector2(160, 320)
	progress_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	progress_bar.show_percentage = false
	progress_bar.pivot_offset = Vector2(40, 560) 
	progress_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.05, 0.0, 0.02, 0.9)
	sb_bg.set_corner_radius_all(40)
	sb_bg.set_border_width_all(4)
	sb_bg.border_color = Color(0.4, 0.3, 0.0)
	
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = Color(1.0, 0.7, 0.0)
	sb_fill.set_corner_radius_all(40)
	sb_fill.shadow_color = Color(1.0, 0.6, 0.0, 0.6)
	sb_fill.shadow_size = 20
	
	progress_bar.add_theme_stylebox_override("background", sb_bg)
	progress_bar.add_theme_stylebox_override("fill", sb_fill)
	roadmap_area.add_child(progress_bar)
	
	# --- Juicy animation mouhahaha ---
	progress_bar.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
			t.tween_property(progress_bar, "scale", Vector2(1.25, 0.9), 0.2)
			sb_fill.shadow_size = 70
			var t_back = create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
			t_back.tween_property(progress_bar, "scale", Vector2.ONE, 0.5).set_delay(0.15)
			t_back.tween_property(sb_fill, "shadow_size", 20, 0.5).set_delay(0.15)
			
			var sm = get_node_or_null("/root/SoundManager")
			if sm: sm.play_sfx("click")
	)

	var idle_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.tween_property(sb_fill, "bg_color", Color(1.0, 0.95, 0.4), 1.2)
	idle_tween.parallel().tween_property(sb_fill, "shadow_size", 45, 1.2)
	idle_tween.chain().tween_property(sb_fill, "bg_color", Color(1.0, 0.7, 0.0), 1.2)
	idle_tween.parallel().tween_property(sb_fill, "shadow_size", 20, 1.2)

	# --- 4. Gallerie des achievements ---
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	hbox.add_child(scroll_container)

	var grid_pad = MarginContainer.new()
	grid_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_pad.add_theme_constant_override("margin_left", 35) 
	grid_pad.add_theme_constant_override("margin_right", 35)
	grid_pad.add_theme_constant_override("margin_top", 30)
	grid_pad.add_theme_constant_override("margin_bottom", 80)
	scroll_container.add_child(grid_pad)

	grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 40)
	grid_pad.add_child(grid)

func _setup_back_button():
	back_btn = Button.new()
	back_btn.text = "< RETURN TO REALM"
	back_btn.position = Vector2(60, 40)
	back_btn.custom_minimum_size = Vector2(220, 60)
	back_btn.pivot_offset = Vector2(110, 30)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.0, 0.02, 0.9)
	sb.set_corner_radius_all(15)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.8, 0.6, 0.1)
	sb.shadow_color = Color(0,0,0,0.5)
	sb.shadow_size = 10
	
	back_btn.add_theme_stylebox_override("normal", sb)
	back_btn.add_theme_stylebox_override("hover", sb)
	back_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	back_btn.mouse_entered.connect(func():
		var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(back_btn, "scale", Vector2(1.1, 1.1), 0.3)
		t.tween_property(back_btn, "position:x", 70.0, 0.3)
		sb.border_color = Color(1.0, 0.9, 0.5)
		sb.shadow_color = Color(1.0, 0.8, 0.0, 0.3)
		sb.shadow_size = 20
		var sm = get_node_or_null("/root/SoundManager")
		if sm: sm.play_sfx("hover")
	)
	back_btn.mouse_exited.connect(func():
		var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(back_btn, "scale", Vector2.ONE, 0.3)
		t.tween_property(back_btn, "position:x", 60.0, 0.3)
		sb.border_color = Color(0.8, 0.6, 0.1)
		sb.shadow_color = Color(0,0,0,0.5)
		sb.shadow_size = 10
	)
	
	back_btn.pressed.connect(_on_back_pressed)
	add_child(back_btn)

func _populate_gallery():
	var am = get_node_or_null("/root/AchievementManager")
	if not am: return
	var db = am.get("DATABASE")
	var unlocked = am.get("unlocked")
	if db == null or unlocked == null: return
	
	for ach in db:
		var is_unlocked = unlocked.has(ach["id"])
		var is_rare = ach.get("is_rare", false)
		
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(560, 140)
		panel.pivot_offset = panel.custom_minimum_size / 2.0 
		panel.mouse_filter = Control.MOUSE_FILTER_STOP 
		
		var sb = StyleBoxFlat.new()
		sb.set_corner_radius_all(20)
		sb.set_border_width_all(3)
		
		if is_unlocked:
			sb.bg_color = Color(0.12, 0.08, 0.08, 0.9)
			sb.border_color = Color(1.0, 0.5, 0.0) if is_rare else Color("FFD700")
			if is_rare:
				sb.shadow_color = Color(1.0, 0.4, 0.0, 0.5)
				sb.shadow_size = 25
		else:
			sb.bg_color = Color(0.05, 0.02, 0.02, 0.8)
			sb.border_color = Color(0.3, 0.1, 0.1)
		panel.add_theme_stylebox_override("panel", sb)
		
		panel.mouse_entered.connect(func():
			var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
			t.tween_property(panel, "scale", Vector2(1.08, 1.08), 0.4)
			t.tween_property(panel, "rotation", deg_to_rad(randf_range(-2.0, 2.0)), 0.3)
			if is_unlocked:
				sb.bg_color = Color(0.2, 0.1, 0.1, 1.0)
				sb.shadow_size = 45 if is_rare else 25
				sb.shadow_color.a = 0.8
			var sm = get_node_or_null("/root/SoundManager")
			if sm: sm.play_sfx("hover")
		)
		panel.mouse_exited.connect(func():
			var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			t.tween_property(panel, "scale", Vector2.ONE, 0.5)
			t.tween_property(panel, "rotation", 0.0, 0.4)
			if is_unlocked:
				sb.bg_color = Color(0.12, 0.08, 0.08, 0.9)
				sb.shadow_size = 25 if is_rare else 0
				sb.shadow_color.a = 0.5 if is_rare else 0.0
		)
		
		var icon = AchievementIcon.new()
		icon.custom_minimum_size = Vector2(100, 100)
		icon.position = Vector2(20, 20)
		panel.add_child(icon)
		icon.set_data(ach["id"], is_unlocked, is_rare)
		
		var ach_title = Label.new()
		ach_title.text = ach["name"]["ENGLISH"] if is_unlocked else "???"
		ach_title.position = Vector2(140, 20)
		ach_title.add_theme_font_size_override("font_size", 28)
		ach_title.add_theme_color_override("font_color", Color(1.0, 0.6, 0.0) if (is_unlocked and is_rare) else (Color.WHITE if is_unlocked else Color.GRAY))
		ach_title.add_theme_constant_override("outline_size", 4)
		ach_title.add_theme_color_override("font_outline_color", Color.BLACK)
		panel.add_child(ach_title)
		
		var desc = Label.new()
		desc.position = Vector2(140, 60)
		desc.custom_minimum_size = Vector2(400, 60)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc.add_theme_font_size_override("font_size", 18)
		if is_unlocked:
			desc.text = ach["desc"]["ENGLISH"]
			desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		else:
			desc.text = ach["hint"]
			desc.add_theme_color_override("font_color", Color(0.7, 0.5, 0.5))
		panel.add_child(desc)
		
		grid.add_child(panel)
		gallery_panels.append(panel)

func _update_roadmap():
	var am = get_node_or_null("/root/AchievementManager")
	if not am: return
	var db = am.get("DATABASE")
	var unlocked = am.get("unlocked")
	if db == null or unlocked == null: return
	
	target_unlocked = unlocked.size()
	var total_count = db.size()
	
	progress_bar.max_value = total_count
	
	var step = total_count / 5.0
	for i in range(1, 6):
		var target_val = int(i * step)
		if target_val > total_count: break
		
		var tick = ColorRect.new()
		tick.custom_minimum_size = Vector2(24, 6) 
		var percent = float(target_val) / float(total_count)
		tick.position = Vector2(250, 320 + (560 * (1.0 - percent)) - 3) 
		tick.color = Color("FFD700") if target_unlocked >= target_val else Color(0.3, 0.1, 0.1)
		roadmap_area.add_child(tick)
		
		var tick_lbl = Label.new()
		tick_lbl.text = str(target_val)
		tick_lbl.add_theme_font_size_override("font_size", 24)
		tick_lbl.add_theme_color_override("font_color", tick.color)
		tick_lbl.position = tick.position + Vector2(35, -16)
		roadmap_area.add_child(tick_lbl)

func _play_enter_animation():
	var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	self.modulate.a = 1.0
	bg.modulate.a = 0.0
	t.tween_property(bg, "modulate:a", 1.0, 1.2)
	
	roadmap_area.position.x -= 150
	roadmap_area.modulate.a = 0.0
	t.tween_property(roadmap_area, "position:x", roadmap_area.position.x + 150, 1.2).set_trans(Tween.TRANS_BACK)
	t.tween_property(roadmap_area, "modulate:a", 1.0, 1.0)
	
	# Un pop explosif du compteur
	counter_label.scale = Vector2.ZERO
	t.tween_property(counter_label, "scale", Vector2.ONE, 1.0).set_delay(0.6).set_trans(Tween.TRANS_ELASTIC)
	
	progress_bar.value = 0
	t.chain().tween_property(progress_bar, "value", target_unlocked, 2.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	var card_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for i in range(gallery_panels.size()):
		var p = gallery_panels[i]
		var delay = 0.4 + (i * 0.06) 
		
		p.modulate.a = 0.0
		p.scale = Vector2(0.3, 0.3)
		p.rotation = deg_to_rad(15)
		
		card_tween.tween_property(p, "modulate:a", 1.0, 0.5).set_delay(delay)
		card_tween.tween_property(p, "scale", Vector2.ONE, 0.7).set_delay(delay)
		card_tween.tween_property(p, "rotation", 0.0, 0.7).set_delay(delay)

func _on_back_pressed():
	back_btn.disabled = true
	var sm = get_node_or_null("/root/SoundManager")
	if sm: sm.play_sfx("click")
	
	var fader = ColorRect.new()
	fader.color = Color.BLACK
	fader.modulate.a = 0.0
	fader.set_anchors_preset(Control.PRESET_FULL_RECT)
	fader.z_index = 4000
	add_child(fader)
	
	var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(fader, "modulate:a", 1.0, 0.6) 
	t.chain().tween_callback(func(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn"))
