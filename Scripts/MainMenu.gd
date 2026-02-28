extends Control

# --- CONFIGURATION ---
const FONT_BUTTONS = ["Trebuchet MS", "Verdana", "Arial Black", "Sans-Serif"]
const FONT_BODY = ["Trebuchet MS", "Verdana", "Arial", "Sans-Serif"]
const FONT_TITLE = ["Rockybilly", "Trebuchet MS", "Verdana", "Arial Black", "Sans-Serif"] 

const C_GOLD = Color("FFD700")
const C_GOLD_GLOW = Color(1.0, 0.9, 0.5, 1.0)
const C_DARK_RED = Color(0.1, 0.0, 0.02, 0.85)

var title_label: Label
var buttons: Array = []
var active_overlay: Control = null
var floating_whatsnew: Button

var how_to_page: int = 0
var how_to_text: RichTextLabel
var how_to_title: Label
var htp_visuals: Control

# Variable des paramètres
var res_list = [
	Vector2(1024, 768), Vector2(1280, 720), Vector2(1280, 1024), 
	Vector2(1366, 768), Vector2(1440, 900), Vector2(1600, 900), 
	Vector2(1920, 1080), Vector2(2560, 1080), Vector2(2560, 1440), Vector2(3840, 2160)
]
var fps_list = [15, 30, 60, 120, 240, 0]

const HOW_TO_SLIDES = [
	{
		"title": "I. The Objective",
		"text": "[center]\nWelcome to [color=#FFD700]Liliales[/color].\n\nYour goal is to acquire the most Gold over 5 rounds by winning tricks. \nEach round, you will draft a hand of cards, and then battle to take control of the board.\n\nBut beware the [color=#9900FF]Lilies[/color]... they carry a heavy toll.[/center]"
	},
	{
		"title": "II. The Draft",
		"text": "[center]\nBefore battle begins, players must [color=#FFD700]Draft[/color] their hand.\n\nYou will be presented with a set of cards. Select the required amount and hit Confirm. \nThe remaining cards are passed to the player on your left.\n\nPlan ahead. A balanced hand is a surviving hand.[/center]"
	},
	{
		"title": "III. The Trick",
		"text": "[center]\nThe first player leads with a card, setting the [color=#FFD700]Leading Suit[/color].\n\nTo win the trick, you must play a card of the [color=#FFD700]SAME SUIT[/color] with a higher rank.\nYou may play any card you wish, but if it does not match the Leading Suit, it is considered a [color=#AAAAAA]Fold[/color] and cannot win.\n\n[color=#FFD700]Exception:[/color] You may never play a Lily of a different suit unless it is your last card.[/center]"
	},
	{
		"title": "IV. Jokers (The Void)",
		"text": "[center]\nCards marked with a [color=#FFFFFF]V[/color] are [color=#AAAAAA]Void Cards[/color] (Jokers).\n\nVoid cards are raw power. They ignore the Leading Suit entirely. \nIf you play a Void card, you will automatically win the trick against any standard colored cards, assuming your Void's rank is the highest among other Voids played.\n\nThey are the ultimate trump cards.[/center]"
	},
	{
		"title": "V. The Lilies",
		"text": "[center]\nThe [color=#9900FF]Rank 8[/color] cards are the [color=#9900FF]Lilies[/color].\n\nWinning a trick is normally worth [color=#FFD700]+3 Gold[/color]. \nHowever, for EVERY Lily present in the trick pile, the winner LOSES [color=#FF0000]-10 Gold[/color].\n\nUse Lilies to poison tricks you know you are going to lose, forcing your enemies into ruin.[/center]"
	}
]

func _ready():
	_spawn_ambient_embers()
	_setup_title()
	_setup_version_text()
	_setup_buttons()
	_setup_whats_new_button()
	_play_intro_animation()
	
	if Global.has_method("load_settings"):
		_apply_current_settings()

func _process(delta):
	if htp_visuals and active_overlay != null:
		htp_visuals.queue_redraw()
		
	if floating_whatsnew and active_overlay == null:
		var b_wave = sin(Time.get_ticks_msec() / 400.0) * 10.0
		floating_whatsnew.position.y = lerp(floating_whatsnew.position.y, 40.0 + b_wave, 8.0 * delta)

func _spawn_ambient_embers():
	var embers = CPUParticles2D.new()
	embers.position = Vector2(1920 / 2.0, 1080)
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(1920 / 2.0, 100)
	embers.amount = 80
	embers.lifetime = 6.0
	embers.gravity = Vector2(0, -30) 
	embers.initial_velocity_min = 10.0
	embers.initial_velocity_max = 40.0
	embers.scale_amount_min = 2.0
	embers.scale_amount_max = 6.0
	embers.color = C_GOLD
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(0.2, 0.6)) 
	curve.add_point(Vector2(1.0, 0.0))
	embers.scale_amount_curve = curve
	add_child(embers)
	embers.z_index = -10 

func _setup_title():
	var font: Font
	if ResourceLoader.exists("res://Rockybilly.ttf"): font = load("res://Rockybilly.ttf")
	elif ResourceLoader.exists("res://Assets/Fonts/Rockybilly.ttf"): font = load("res://Assets/Fonts/Rockybilly.ttf")
	else:
		font = SystemFont.new()
		font.font_names = PackedStringArray(FONT_TITLE)
		font.font_weight = 900 
		font.font_italic = true
	
	title_label = Label.new()
	title_label.text = "Liliales" 
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 102) 
	title_label.add_theme_color_override("font_color", C_GOLD)
	title_label.add_theme_constant_override("outline_size", 12)
	title_label.add_theme_color_override("font_outline_color", Color(0.05, 0.0, 0.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title_label.add_theme_constant_override("shadow_offset_x", 0)
	title_label.add_theme_constant_override("shadow_offset_y", 15)
	
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.custom_minimum_size = Vector2(1920, 200)
	title_label.position = Vector2(0, 100)
	title_label.pivot_offset = title_label.custom_minimum_size / 2.0 
	
	var sm = ShaderMaterial.new()
	var sh = Shader.new()
	sh.code = """
	shader_type canvas_item;
	void fragment() {
		vec4 font_mask = texture(TEXTURE, UV);
		float sweep = pow(sin(UV.x * 4.0 - UV.y * 2.0 - TIME * 2.5) * 0.5 + 0.5, 8.0);
		vec3 glow = vec3(1.0, 0.9, 0.6) * sweep * 1.5;
		COLOR = vec4(COLOR.rgb + glow, COLOR.a * font_mask.a);
	}
	"""
	sm.shader = sh
	title_label.material = sm
	add_child(title_label)

func _setup_version_text():
	var v_label = Label.new()
	v_label.text = "Version 2.02 Stable - Created by Lehfel"
	var font = SystemFont.new()
	font.font_names = PackedStringArray(FONT_BODY)
	v_label.add_theme_font_override("font", font)
	v_label.add_theme_font_size_override("font_size", 24)
	v_label.add_theme_color_override("font_color", Color(1,1,1,0.6))
	v_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v_label.custom_minimum_size = Vector2(800, 40)
	v_label.position = Vector2(1920 - 800 - 30, 1030) 
	add_child(v_label)

func _setup_buttons():
	var menu_options = ["PLAY", "HOW TO PLAY", "SETTINGS", "CREDITS", "QUIT"]
	var font = SystemFont.new()
	font.font_names = PackedStringArray(FONT_BUTTONS)
	font.font_weight = 800
	
	var start_y = 480.0
	var btn_spacing = 100.0
	var btn_width = 400.0
	var btn_height = 70.0
	var center_x = (1920.0 - btn_width) / 2.0
	
	for i in range(menu_options.size()):
		var btn = Button.new()
		btn.text = menu_options[i]
		btn.custom_minimum_size = Vector2(btn_width, btn_height)
		var target_y = start_y + (i * btn_spacing)
		btn.position = Vector2(center_x, target_y)
		btn.set_meta("base_y", target_y)
		btn.pivot_offset = Vector2(btn_width / 2.0, btn_height / 2.0) 
		
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 28)
		btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		btn.add_theme_color_override("font_hover_color", C_GOLD_GLOW)
		
		var sb_normal = StyleBoxFlat.new()
		sb_normal.bg_color = C_DARK_RED
		sb_normal.set_corner_radius_all(15)
		sb_normal.set_border_width_all(3)
		sb_normal.border_color = Color(0.4, 0.3, 0.1)
		
		var sb_hover = sb_normal.duplicate()
		sb_hover.bg_color = Color(0.2, 0.0, 0.05, 0.95)
		sb_hover.border_color = C_GOLD_GLOW
		
		btn.add_theme_stylebox_override("normal", sb_normal)
		btn.add_theme_stylebox_override("hover", sb_hover)
		btn.add_theme_stylebox_override("pressed", sb_hover)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new()) 
		
		btn.mouse_entered.connect(_on_btn_hover.bind(btn))
		btn.mouse_exited.connect(_on_btn_unhover.bind(btn))
		btn.button_down.connect(_on_btn_down.bind(btn))
		btn.pressed.connect(_on_btn_pressed.bind(btn.text))
		
		add_child(btn)
		buttons.append(btn)

func _setup_whats_new_button():
	floating_whatsnew = Button.new()
	floating_whatsnew.text = "✨ What's New!"
	floating_whatsnew.custom_minimum_size = Vector2(250, 60)
	floating_whatsnew.pivot_offset = Vector2(125, 30)
	floating_whatsnew.position = Vector2(1620, 40)
	
	var font = SystemFont.new()
	font.font_names = PackedStringArray(FONT_BODY)
	font.font_weight = 800
	floating_whatsnew.add_theme_font_override("font", font)
	floating_whatsnew.add_theme_font_size_override("font_size", 22)
	floating_whatsnew.add_theme_color_override("font_color", C_GOLD)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	sb.set_corner_radius_all(30)
	sb.set_border_width_all(2)
	sb.border_color = C_GOLD
	floating_whatsnew.add_theme_stylebox_override("normal", sb)
	
	var sb_hover = sb.duplicate()
	sb_hover.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	sb_hover.border_color = Color.WHITE
	floating_whatsnew.add_theme_stylebox_override("hover", sb_hover)
	floating_whatsnew.add_theme_stylebox_override("pressed", sb_hover)
	floating_whatsnew.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	floating_whatsnew.mouse_entered.connect(_on_btn_hover.bind(floating_whatsnew))
	floating_whatsnew.mouse_exited.connect(_on_btn_unhover.bind(floating_whatsnew))
	floating_whatsnew.button_down.connect(_on_btn_down.bind(floating_whatsnew))
	floating_whatsnew.pressed.connect(_on_btn_pressed.bind("WHATS_NEW"))
	
	add_child(floating_whatsnew)

func _apply_current_settings():
	if not Global.settings.has("RES_INDEX"): Global.settings["RES_INDEX"] = 6
	if not Global.settings.has("MODE_INDEX"): Global.settings["MODE_INDEX"] = 0
	if not Global.settings.has("FPS_INDEX"): Global.settings["FPS_INDEX"] = 2
	
	_apply_resolution(Global.settings["RES_INDEX"])
	_apply_window_mode(Global.settings["MODE_INDEX"])
	_apply_fps(Global.settings["FPS_INDEX"])

func _apply_resolution(idx: int):
	if idx >= 0 and idx < res_list.size():
		DisplayServer.window_set_size(res_list[idx])
		var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(screen_center - window_size / 2)

func _apply_window_mode(idx: int):
	match idx:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _apply_fps(idx: int):
	if idx >= 0 and idx < fps_list.size():
		Engine.max_fps = fps_list[idx]

func _play_intro_animation():
	var fader = ColorRect.new()
	fader.color = Color.BLACK
	fader.set_anchors_preset(Control.PRESET_FULL_RECT)
	fader.z_index = 2000
	add_child(fader)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(fader, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_callback(fader.queue_free)
	
	title_label.modulate.a = 0.0
	floating_whatsnew.modulate.a = 0.0
	floating_whatsnew.scale = Vector2.ZERO
	
	for btn in buttons:
		btn.modulate.a = 0.0
		var target_y = btn.get_meta("base_y")
		btn.position.y = target_y + 150
		btn.scale = Vector2(0.8, 0.8)
		
	var t = create_tween().set_parallel(true)
	t.tween_property(title_label, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_CUBIC)
	
	t.tween_property(floating_whatsnew, "modulate:a", 1.0, 0.8).set_delay(1.0)
	t.tween_property(floating_whatsnew, "scale", Vector2.ONE, 0.8).set_delay(1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		var delay = 0.3 + (i * 0.15) 
		var target_y = btn.get_meta("base_y")
		t.tween_property(btn, "modulate:a", 1.0, 0.5).set_delay(delay)
		t.tween_property(btn, "position:y", target_y, 0.8).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.8).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_btn_hover(btn: Button):
	var t = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.2)
	var sm = get_node_or_null("/root/SoundManager")
	if sm and sm.has_method("play_sfx"): sm.play_sfx("hover")

func _on_btn_unhover(btn: Button):
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)

func _on_btn_down(btn: Button):
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1)
	var sm = get_node_or_null("/root/SoundManager")
	if sm and sm.has_method("play_sfx"): sm.play_sfx("click")

func _on_btn_pressed(btn_name: String):
	match btn_name:
		"PLAY":
			_open_overlay("YOUR NAME", Callable(self, "_build_name_input"))
		"HOW TO PLAY":
			_open_overlay("HOW TO PLAY", Callable(self, "_build_how_to"))
		"SETTINGS":
			_open_overlay("SETTINGS", Callable(self, "_build_settings"))
		"CREDITS":
			_open_overlay("CREDITS", Callable(self, "_build_credits"))
		"WHATS_NEW":
			_open_overlay("CHANGELOG", Callable(self, "_build_changelog"))
		"QUIT":
			get_tree().quit()

func _trigger_play_cinematic():
	for b in buttons: b.disabled = true
	if floating_whatsnew: floating_whatsnew.disabled = true
	
	var fader = ColorRect.new()
	fader.color = Color.BLACK
	fader.modulate.a = 0.0
	fader.set_anchors_preset(Control.PRESET_FULL_RECT)
	fader.z_index = 2000
	add_child(fader)
	
	var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(title_label, "scale", Vector2(1.5, 1.5), 0.8)
	t.tween_property(title_label, "modulate:a", 0.0, 0.8)
	t.tween_property(floating_whatsnew, "position:y", -100, 0.6)
	
	for i in range(buttons.size()):
		t.tween_property(buttons[i], "position:y", 1200, 0.6).set_delay(i * 0.05).set_trans(Tween.TRANS_BACK)
		t.tween_property(buttons[i], "modulate:a", 0.0, 0.6).set_delay(i * 0.05)
	
	t.tween_property(fader, "modulate:a", 1.0, 0.8).set_delay(0.1)
	
	t.chain().tween_callback(func():
		if Global.has_method("goto_scene"): Global.goto_scene("res://Scenes/Game.tscn")
		else: get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	)

func _open_overlay(title_str: String, builder_func: Callable):
	if active_overlay != null: return
	
	active_overlay = Control.new()
	active_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	active_overlay.z_index = 200
	add_child(active_overlay)
	
	var dim_bg = ColorRect.new()
	dim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim_bg.color = Color(0,0,0,0)
	active_overlay.add_child(dim_bg)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(1100, 750)
	panel.position = Vector2((1920-1100)/2.0, (1080-750)/2.0)
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.08, 0.08, 0.98)
	sb.set_corner_radius_all(25)
	sb.set_border_width_all(4)
	sb.border_color = C_GOLD
	panel.add_theme_stylebox_override("panel", sb)
	active_overlay.add_child(panel)
	
	var f_title = SystemFont.new()
	f_title.font_names = PackedStringArray(FONT_BUTTONS) 
	f_title.font_weight = 800
	
	var title = Label.new()
	title.text = title_str
	title.add_theme_font_override("font", f_title)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", C_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 30)
	title.custom_minimum_size = Vector2(1100, 60)
	panel.add_child(title)
	
	var content_area = Control.new()
	content_area.position = Vector2(50, 120)
	content_area.custom_minimum_size = Vector2(1000, 500)
	panel.add_child(content_area)
	
	builder_func.call(content_area)
	
	var btn_close = Button.new()
	btn_close.text = "CLOSE"
	btn_close.custom_minimum_size = Vector2(200, 60)
	btn_close.position = Vector2((1100-200)/2.0, 650)
	var f_btn = SystemFont.new()
	f_btn.font_names = PackedStringArray(FONT_BODY)
	f_btn.font_weight = 800
	btn_close.add_theme_font_override("font", f_btn)
	btn_close.add_theme_font_size_override("font_size", 24)
	var sb_c = StyleBoxFlat.new()
	sb_c.bg_color = C_DARK_RED
	sb_c.set_corner_radius_all(10); sb_c.set_border_width_all(2); sb_c.border_color = C_GOLD
	btn_close.add_theme_stylebox_override("normal", sb_c)
	btn_close.add_theme_stylebox_override("hover", sb_c)
	btn_close.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_close.pressed.connect(_close_overlay)
	panel.add_child(btn_close)
	
	panel.scale = Vector2.ZERO
	var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(dim_bg, "color:a", 0.8, 0.4)
	t.tween_property(panel, "scale", Vector2.ONE, 0.4)

func _close_overlay():
	if not active_overlay: return
	var p = active_overlay.get_child(1) 
	var bg = active_overlay.get_child(0) 
	var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(p, "scale", Vector2.ZERO, 0.3)
	t.tween_property(bg, "color:a", 0.0, 0.3)
	t.chain().tween_callback(func():
		active_overlay.queue_free()
		active_overlay = null
		htp_visuals = null
	)

func _build_name_input(container: Control):
	var f = SystemFont.new()
	f.font_names = PackedStringArray(FONT_BODY); f.font_weight = 800
	
	var lbl = Label.new()
	lbl.text = "Enter Your Name, Champion:"
	lbl.add_theme_font_override("font", f)
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(1000, 40)
	lbl.position = Vector2(0, 100)
	container.add_child(lbl)
	
	var input = LineEdit.new()
	input.text = Global.settings.get("PLAYER_NAME", "Player")
	input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input.add_theme_font_override("font", f)
	input.add_theme_font_size_override("font_size", 36)
	input.custom_minimum_size = Vector2(500, 80)
	input.position = Vector2((1000 - 500)/2.0, 200)
	
	var sb_in = StyleBoxFlat.new()
	sb_in.bg_color = Color(0.1, 0.1, 0.1)
	sb_in.set_corner_radius_all(15)
	sb_in.border_color = C_GOLD
	sb_in.set_border_width_all(2)
	input.add_theme_stylebox_override("normal", sb_in)
	input.add_theme_stylebox_override("focus", sb_in)
	container.add_child(input)
	
	var start_btn = Button.new()
	start_btn.text = "ENTER ARENA"
	start_btn.custom_minimum_size = Vector2(400, 70)
	start_btn.position = Vector2((1000 - 400)/2.0, 350)
	start_btn.add_theme_font_override("font", f)
	start_btn.add_theme_font_size_override("font_size", 32)
	start_btn.add_theme_color_override("font_color", Color.BLACK)
	
	var sb_btn = StyleBoxFlat.new()
	sb_btn.bg_color = C_GOLD
	sb_btn.set_corner_radius_all(15)
	start_btn.add_theme_stylebox_override("normal", sb_btn)
	start_btn.add_theme_stylebox_override("hover", sb_btn)
	start_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	start_btn.pressed.connect(func():
		var final_name = input.text.strip_edges()
		if final_name == "": final_name = "Player"
		Global.settings["PLAYER_NAME"] = final_name
		if Global.has_method("save_settings"): Global.save_settings()
		_close_overlay()
		_trigger_play_cinematic()
	)
	container.add_child(start_btn)

func _build_how_to(container: Control):
	how_to_page = 0
	
	htp_visuals = Control.new()
	htp_visuals.custom_minimum_size = Vector2(1000, 220)
	htp_visuals.position = Vector2(0, 0)
	htp_visuals.draw.connect(_draw_htp_visuals)
	container.add_child(htp_visuals)
	
	var f = SystemFont.new()
	f.font_names = PackedStringArray(FONT_BODY); f.font_weight = 800
	
	how_to_title = Label.new()
	how_to_title.add_theme_font_override("font", f)
	how_to_title.add_theme_font_size_override("font_size", 32)
	how_to_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	how_to_title.custom_minimum_size = Vector2(1000, 40)
	how_to_title.position = Vector2(0, 220)
	container.add_child(how_to_title)
	
	how_to_text = RichTextLabel.new()
	how_to_text.bbcode_enabled = true
	how_to_text.custom_minimum_size = Vector2(1000, 200)
	how_to_text.position = Vector2(0, 270)
	how_to_text.add_theme_font_override("normal_font", f)
	how_to_text.add_theme_font_size_override("normal_font_size", 24)
	container.add_child(how_to_text)
	
	var btn_prev = Button.new(); btn_prev.text = "< PREV"
	var btn_next = Button.new(); btn_next.text = "NEXT >"
	
	for b in [btn_prev, btn_next]:
		b.custom_minimum_size = Vector2(150, 50)
		b.add_theme_font_override("font", f)
		b.add_theme_font_size_override("font_size", 20)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.2, 0.2, 0.2)
		sb.set_corner_radius_all(10)
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		container.add_child(b)
		
	btn_prev.position = Vector2(0, 535)
	btn_next.position = Vector2(850, 535)
	
	btn_prev.pressed.connect(func(): _change_how_to_page(-1))
	btn_next.pressed.connect(func(): _change_how_to_page(1))
	
	_update_how_to_visuals()

func _change_how_to_page(dir: int):
	how_to_page += dir
	if how_to_page < 0: how_to_page = HOW_TO_SLIDES.size() - 1
	elif how_to_page >= HOW_TO_SLIDES.size(): how_to_page = 0
		
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(how_to_text, "modulate:a", 0.0, 0.15)
	t.tween_callback(_update_how_to_visuals)
	t.tween_property(how_to_text, "modulate:a", 1.0, 0.15)

func _update_how_to_visuals():
	var slide = HOW_TO_SLIDES[how_to_page]
	how_to_title.text = slide["title"]
	how_to_text.text = slide["text"]

func _draw_htp_visuals():
	if not htp_visuals: return
	var t = Time.get_ticks_msec() / 1000.0
	var cx = 500.0
	var cy = 110.0
	
	match how_to_page:
		0: 
			var w = sin(t * 3.0) * 15.0
			var scale_w = cos(t * 2.0) * 0.1 + 1.0
			htp_visuals.draw_circle(Vector2(cx, cy + w), 40 * scale_w, Color(1.0, 0.8, 0.2, 0.6)) 
			htp_visuals.draw_circle(Vector2(cx, cy + w), 30 * scale_w, C_GOLD)
		1: 
			var cycle = fmod(t, 2.5)
			for i in range(3):
				var px = cx + (i - 1) * 100
				var py = cy
				var is_selected = (i == 1 and cycle > 1.0)
				var c_color = Color(0.2, 0.2, 0.2)
				if is_selected:
					py -= 30
					c_color = C_GOLD
				htp_visuals.draw_rect(Rect2(px - 35, py - 50, 70, 100), c_color)
				htp_visuals.draw_rect(Rect2(px - 32, py - 47, 64, 94), Color(0.8, 0.1, 0.1))
		2: 
			var cycle = fmod(t, 2.0)
			htp_visuals.draw_rect(Rect2(cx - 35, cy - 50, 70, 100), Color.WHITE)
			htp_visuals.draw_rect(Rect2(cx - 32, cy - 47, 64, 94), Color(0.2, 0.2, 0.8)) 
			if cycle > 0.5:
				var fly_x = lerp(cx + 200, cx + 20, min(1.0, (cycle - 0.5) * 4.0))
				htp_visuals.draw_rect(Rect2(fly_x - 35, cy - 50, 70, 100), Color.WHITE)
				htp_visuals.draw_rect(Rect2(fly_x - 32, cy - 47, 64, 94), Color(0.2, 0.2, 0.8))
		3: 
			var cycle = fmod(t, 2.0)
			htp_visuals.draw_rect(Rect2(cx - 35, cy - 50 + 20, 70, 100), Color.WHITE)
			htp_visuals.draw_rect(Rect2(cx - 32, cy - 47 + 20, 64, 94), Color(0.8, 0.2, 0.2)) 
			if cycle > 0.8:
				var drop_y = lerp(cy - 200, cy, min(1.0, (cycle - 0.8) * 6.0))
				if cycle > 0.95 and cycle < 1.2: drop_y += randf_range(-5, 5)
				htp_visuals.draw_rect(Rect2(cx - 45, drop_y - 60, 90, 120), C_GOLD)
				htp_visuals.draw_rect(Rect2(cx - 42, drop_y - 57, 84, 114), Color.BLACK)
		4: 
			var pulse = fmod(t * 2.0, 1.0)
			htp_visuals.draw_circle(Vector2(cx, cy), pulse * 120, Color(0.5, 0.0, 0.8, 1.0 - pulse))
			htp_visuals.draw_rect(Rect2(cx - 35, cy - 50, 70, 100), Color(0.5, 0.0, 0.8))
			htp_visuals.draw_rect(Rect2(cx - 32, cy - 47, 64, 94), Color(0.1, 0.1, 0.1))

func _build_settings(container: Control):
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(950, 600)
	vbox.add_theme_constant_override("separation", 25)
	scroll.add_child(vbox)
	
	var f = SystemFont.new()
	f.font_names = PackedStringArray(FONT_BODY); f.font_weight = 700
	
	var create_row = func(title: String, control: Control):
		var h = HBoxContainer.new()
		var l = Label.new(); l.text = title; l.custom_minimum_size = Vector2(450, 50)
		l.add_theme_font_override("font", f); l.add_theme_font_size_override("font_size", 28)
		h.add_child(l); h.add_child(control)
		vbox.add_child(h)
	
	var ob_res = OptionButton.new()
	ob_res.custom_minimum_size = Vector2(400, 50)
	for r in res_list: ob_res.add_item("%dx%d" % [r.x, r.y])
	ob_res.select(Global.settings.get("RES_INDEX", 6))
	ob_res.item_selected.connect(func(idx): 
		Global.settings["RES_INDEX"] = idx; Global.save_settings()
		_apply_resolution(idx)
	)
	create_row.call("Resolution", ob_res)
	
	var ob_win = OptionButton.new()
	ob_win.custom_minimum_size = Vector2(400, 50)
	ob_win.add_item("Windowed"); ob_win.add_item("Fullscreen"); ob_win.add_item("Borderless")
	ob_win.select(Global.settings.get("MODE_INDEX", 0))
	ob_win.item_selected.connect(func(idx): 
		Global.settings["MODE_INDEX"] = idx; Global.save_settings()
		_apply_window_mode(idx)
	)
	create_row.call("Window Mode", ob_win)
	
	var ob_fps = OptionButton.new()
	ob_fps.custom_minimum_size = Vector2(400, 50)
	ob_fps.add_item("15 FPS"); ob_fps.add_item("30 FPS"); ob_fps.add_item("60 FPS")
	ob_fps.add_item("120 FPS"); ob_fps.add_item("240 FPS"); ob_fps.add_item("Unlimited")
	ob_fps.select(Global.settings.get("FPS_INDEX", 2))
	ob_fps.item_selected.connect(func(idx): 
		Global.settings["FPS_INDEX"] = idx; Global.save_settings()
		_apply_fps(idx)
	)
	create_row.call("Max FPS", ob_fps)
	
	var ob_diff = OptionButton.new()
	ob_diff.custom_minimum_size = Vector2(400, 50)
	ob_diff.add_item("EASY"); ob_diff.add_item("NORMAL"); ob_diff.add_item("HARD"); ob_diff.add_item("IMPOSSIBLE")
	var diff_map = {"EASY":0, "NORMAL":1, "HARD":2, "IMPOSSIBLE":3}
	ob_diff.select(diff_map.get(Global.settings.get("DIFFICULTY", "NORMAL"), 1))
	ob_diff.item_selected.connect(func(idx): 
		var diffs = ["EASY", "NORMAL", "HARD", "IMPOSSIBLE"]
		Global.settings["DIFFICULTY"] = diffs[idx]; Global.save_settings()
	)
	create_row.call("Bot Difficulty", ob_diff)

func _build_credits(container: Control):
	var r = RichTextLabel.new()
	r.bbcode_enabled = true
	r.custom_minimum_size = Vector2(1000, 500)
	
	var f = SystemFont.new()
	f.font_names = PackedStringArray(FONT_BODY); f.font_weight = 700
	r.add_theme_font_override("normal_font", f)
	r.add_theme_font_size_override("normal_font_size", 28)
	
	r.text = "[center]\n[wave amp=30 freq=2][color=#FFD700]-- LILIALES --[/color][/wave]\n\n"
	r.text += "[color=#AAAAAA]Original Idea by:[/color]\n[color=#FFFFFF]Wiliam Roger Keurantjes[/color]\n\n"
	r.text += "[color=#AAAAAA]Art & Aesthetics by:[/color]\n[color=#FFFFFF]Émerik[/color]\n\n"
	r.text += "[color=#AAAAAA]Edited and Directed by:[/color]\n[color=#FFD700]Lehfel[/color]\n\n"
	r.text += "Thank you for playing.[/center]"
	
	container.add_child(r)
	r.position.y = 50
	r.modulate.a = 0.0
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(r, "position:y", 0.0, 1.5)
	t.parallel().tween_property(r, "modulate:a", 1.0, 1.5)

func _build_changelog(container: Control):
	var r = RichTextLabel.new()
	r.bbcode_enabled = true
	r.custom_minimum_size = Vector2(1000, 500)
	
	var f = SystemFont.new()
	f.font_names = PackedStringArray(FONT_BODY); f.font_weight = 700
	r.add_theme_font_override("normal_font", f)
	r.add_theme_font_size_override("normal_font_size", 24)
	
	r.text = "[center][color=#FFD700]Update 2.02 - The Grand Master Polish[/color][/center]\n\n"
	r.text += "[ul]"
	r.text += "Revamped Main Menu with Royal Shaders and Transitions.\n"
	r.text += "Added Name Entry System and integrated Highscores.\n"
	r.text += "How To Play now features live, animated visual demonstrations.\n"
	r.text += "Jokers now gently shockwave cards out of the way on impact.\n"
	r.text += "Lilies cast a purple glowing aura onto the numbers of infected tricks.\n"
	r.text += "Added a massive, suspenseful Podium Cinematic at Round 5.\n"
	r.text += "[/ul]"
	
	container.add_child(r)
