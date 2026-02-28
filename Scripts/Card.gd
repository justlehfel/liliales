extends Node2D

signal clicked(card_node)
signal hovered(card_node)
signal unhovered(card_node)

const BASE_W = 140
const BASE_H = 200
const CORNER_RADIUS = 12
const LILY_RANK = 8

const C_GOLD = Color("FFD700")
const C_WHITE = Color("FFFFFF")
const C_BLACK = Color("101010")
const C_RED = Color("D02020")
const C_BLUE = Color("2050D0")
const C_GREEN = Color("209020")
const C_BACK_RED = Color("400505")
const C_BACK_ORANGE = Color("D09020")
const C_LILY_BG = Color("150505")
const C_LILY_BORDER = Color("600060")

var suit: String = "Red"
var rank: int = 1
var is_face_up: bool = true:
	set(v): is_face_up = v; queue_redraw()

var selected: bool = false:
	set(v):
		selected = v
		if is_drafting:
			var t = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			var s = get_meta("draft_scale", 1.0)
			t.tween_property(self, "scale", Vector2(s*1.15, s*1.15) if v else Vector2(s, s), 0.4)
		queue_redraw()

var is_drafting: bool = false
var target_pos: Vector2 = Vector2.ZERO
var target_rot: float = 0.0
var hover_active: bool = false
var _font: SystemFont
var _move_tween: Tween 
var last_click_time: int = 0 

var number_glow_amt: float = 0.0
var player_tag: String = ""
var aura_rect: ColorRect

func _ready():
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Arial", "Segoe UI", "Verdana", "Roboto", "Sans-Serif"])
	_font.font_weight = 800
	
	aura_rect = ColorRect.new()
	aura_rect.size = Vector2(BASE_W + 260, BASE_H + 260) 
	aura_rect.position = -aura_rect.size / 2
	aura_rect.z_index = -1 
	aura_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Ici je décide d'incarner le shader de la carte à même le script
	var sm = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	uniform vec4 suit_color : source_color;
	void fragment() {
		vec2 uv = UV - 0.5;
		float d = length(uv) * 1.8; 
		float a = atan(uv.y, uv.x);
		float wave = sin(a * 7.0 + TIME * 4.0) * 0.08 + cos(a * 3.0 - TIME * 3.5) * 0.06;
		float aura = smoothstep(0.45, 0.0, d + wave); 
		vec3 col1 = suit_color.rgb * 0.7; 
		vec3 col2 = vec3(0.05, 0.0, 0.2); 
		vec3 mix_col = mix(col1, col2, sin(d * 12.0 - TIME * 6.0) * 0.5 + 0.5);
		float edge_glow = smoothstep(0.1, 0.35, d) * 2.0;
		COLOR = vec4(mix_col * edge_glow, aura);
	}
	"""
	sm.shader = shader
	aura_rect.material = sm
	aura_rect.visible = false
	add_child(aura_rect)

func set_card_data(_suit: String, _rank: int):
	suit = _suit; rank = _rank
	if rank == LILY_RANK:
		aura_rect.visible = true
		var s_col = Color(0.2, 0.0, 0.4) 
		if suit == "Red": s_col = C_RED
		elif suit == "Blue": s_col = C_BLUE
		elif suit == "Green": s_col = C_GREEN
		elif suit in ["Black", "White"]: s_col = Color(0.7, 0.7, 0.8) 
		aura_rect.material.set_shader_parameter("suit_color", s_col)
	else:
		aura_rect.visible = false
	queue_redraw()

func apply_purple_glow():
	var t = create_tween()
	t.tween_property(self, "number_glow_amt", 1.0, 0.5)

func apply_shockwave(center: Vector2, force: float):
	var dir = (position - center).normalized()
	if dir == Vector2.ZERO: dir = Vector2(0, 1) 
	var pushed_pos = target_pos + (dir * force) 
	
	if _move_tween and _move_tween.is_valid(): _move_tween.kill()
	_move_tween = create_tween().set_parallel(false)
	_move_tween.tween_property(self, "position", pushed_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_move_tween.tween_property(self, "position", target_pos, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func move_to(pos: Vector2, rot: float, duration: float = 0.4):
	target_pos = pos
	target_rot = rot
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
		
	_move_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_move_tween.tween_property(self, "position", pos, duration)
	_move_tween.tween_property(self, "rotation", rot, duration)
	
	if get_meta("played", false) == true:
		_move_tween.tween_property(self, "scale", Vector2(1.0, 1.0), duration)

func _process(delta):
	if is_face_up: queue_redraw()
	
	if is_drafting:
		if selected:
			position.y = lerp(position.y, target_pos.y - 35.0, 15.0 * delta)
			position.x = lerp(position.x, target_pos.x, 15.0 * delta)
			rotation = lerp_angle(rotation, 0.0, 15.0 * delta)
		else:
			var wave = sin(Time.get_ticks_msec() / 300.0 + target_pos.x) * 12.0
			var h_lift = -15.0 if hover_active else 0.0
			position.y = lerp(position.y, target_pos.y + wave + h_lift, 12.0 * delta)
			position.x = lerp(position.x, target_pos.x, 12.0 * delta)
			rotation = lerp_angle(rotation, 0.0, 12.0 * delta)
	else:
		if not hover_active and not get_meta("played", false):
			if not (_move_tween and _move_tween.is_running()):
				var t_val = (Time.get_ticks_msec() / 1000.0) + get_instance_id()
				var w_y = sin(t_val * 2.2) * 5.0
				var w_r = sin(t_val * 1.5) * 0.02
				position.y = lerp(position.y, target_pos.y + w_y, 4.0 * delta)
				rotation = lerp_angle(rotation, target_rot + w_r, 4.0 * delta)

func _input(event):
	if not is_face_up: return
	
	# --- Patch pour éviter que tu appuies sur une touche et que tout explose ---
	if not (event is InputEventMouse): return 
	
	var local = make_input_local(event)
	var rect = Rect2(-BASE_W/2, -BASE_H/2, BASE_W, BASE_H)
	
	if rect.has_point(local.position):
		var is_blocked = false
		var my_idx = get_index()
		var siblings = get_parent().get_children()
		
		for i in range(my_idx + 1, siblings.size()):
			var sib = siblings[i]
			if sib is Node2D and sib.visible and "is_face_up" in sib:
				var sib_local = sib.make_input_local(event)
				if Rect2(-BASE_W/2, -BASE_H/2, BASE_W, BASE_H).has_point(sib_local.position):
					is_blocked = true; break
					
		if not is_blocked:
			if event is InputEventMouseMotion:
				if not hover_active:
					hover_active = true
					hovered.emit(self)
				
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_drafting:
					if Time.get_ticks_msec() - last_click_time > 200: 
						last_click_time = Time.get_ticks_msec()
						clicked.emit(self)
					
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if Time.get_ticks_msec() - last_click_time > 200:
					last_click_time = Time.get_ticks_msec()
					clicked.emit(self)
		else:
			if hover_active:
				hover_active = false; unhovered.emit(self)
	else:
		if hover_active:
			hover_active = false; unhovered.emit(self)

func _draw():
	var r_rect = Rect2(-BASE_W/2, -BASE_H/2, BASE_W, BASE_H)
	if not is_face_up: _draw_back(r_rect); return

	var bg = C_BLACK; var border = C_WHITE; var txt = C_WHITE
	match suit:
		"Red": bg = C_RED
		"Blue": bg = C_BLUE
		"Green": bg = C_GREEN
		"White": bg = C_WHITE; border = C_BLACK; txt = C_BLACK
	
	if rank == LILY_RANK and suit not in ["Black", "White"]:
		bg = C_LILY_BG; border = C_LILY_BORDER
	if selected: border = C_GOLD

	draw_style_box(_style(bg, CORNER_RADIUS), r_rect)
	draw_style_box(_border(border, CORNER_RADIUS, 6 if selected else 4), r_rect)

	var prog = fmod(Time.get_ticks_msec(), 3000.0) / 1000.0
	if prog < 0.6:
		var w_total = BASE_W + 100
		var cx = (prog / 0.6) * w_total - 50 - (BASE_W/2)
		var t = 30; var bw = 40; var yt = -BASE_H/2; var yb = BASE_H/2
		var pts = [Vector2(cx+t, yt), Vector2(cx+bw+t, yt), Vector2(cx+bw-t, yb), Vector2(cx-t, yb)]
		for i in range(4): pts[i].x = clamp(pts[i].x, -BASE_W/2, BASE_W/2)
		draw_colored_polygon(pts, Color(1,1,1,0.2))

	if _font:
		var r_str = str(rank)
		var s_str = "V" if suit in ["Black", "White"] else suit.left(1)
		
		var center_sz = 96 if rank < 10 else 80
		var center_y = center_sz * 0.35 
		
		if number_glow_amt > 0.0:
			var glow_col = Color(0.6, 0.0, 1.0, number_glow_amt * 0.7) 
			for i in range(4):
				var offset = Vector2(cos(i * PI/2), sin(i * PI/2)) * 4.0
				draw_string(_font, Vector2(-BASE_W/2, center_y) + offset, r_str, HORIZONTAL_ALIGNMENT_CENTER, BASE_W, center_sz, glow_col)
		
		draw_string(_font, Vector2(-BASE_W/2, center_y), r_str, HORIZONTAL_ALIGNMENT_CENTER, BASE_W, center_sz, txt)
		
		var c_sz = 40 
		var pad_x = 16 
		var pad_y = 16 
		
		var tl = Vector2(-BASE_W/2 + pad_x, -BASE_H/2 + pad_y + c_sz * 0.6)
		draw_string(_font, tl, s_str, HORIZONTAL_ALIGNMENT_LEFT, -1, c_sz, txt)
		
		var br_pos = Vector2(BASE_W/2 - pad_x, BASE_H/2 - pad_y)
		draw_set_transform(br_pos, PI, Vector2.ONE) 
		draw_string(_font, Vector2(0, c_sz * 0.6), s_str, HORIZONTAL_ALIGNMENT_LEFT, -1, c_sz, txt)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		
		if player_tag != "":
			var tag_y = BASE_H / 2 + 25
			var t_sz = 16
			
			for i in range(8):
				var angle = i * (PI / 4.0)
				var offset = Vector2(cos(angle), sin(angle)) * 2.0
				draw_string(_font, Vector2(-BASE_W/2, tag_y) + offset, player_tag, HORIZONTAL_ALIGNMENT_CENTER, BASE_W, t_sz, Color(0,0,0,0.8))
			
			draw_string(_font, Vector2(-BASE_W/2, tag_y), player_tag, HORIZONTAL_ALIGNMENT_CENTER, BASE_W, t_sz, Color.WHITE)

func _draw_back(r):
	draw_style_box(_style(C_BACK_RED, CORNER_RADIUS), r)
	draw_style_box(_border(C_BACK_ORANGE, CORNER_RADIUS, 4), r)
	draw_colored_polygon([Vector2(0,-30), Vector2(25,0), Vector2(0,30), Vector2(-25,0)], C_BACK_ORANGE)

func _style(c, r): var s=StyleBoxFlat.new(); s.bg_color=c; s.set_corner_radius_all(r); return s
func _border(c, r, w): var s=StyleBoxFlat.new(); s.bg_color=Color.TRANSPARENT; s.border_color=c; s.set_border_width_all(w); s.set_corner_radius_all(r); return s
