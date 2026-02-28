extends Button

var accent_color: Color = Color("FFD700") 
var _font: SystemFont
var hover_tween: Tween

func _ready():
	flat = true
	text = "" 
	custom_minimum_size = Vector2(240, 90)
	pivot_offset = custom_minimum_size / 2.0 
	
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Arial", "Segoe UI", "Sans-Serif"])
	_font.font_weight = 700 
	
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	button_down.connect(_on_press)

func _on_hover():
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_unhover():
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func _on_press():
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.1)
	hover_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func animate_hide(callback: Callable):
	disabled = true 
	var t = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "scale", Vector2(0.3, 0.3), 0.25)
	t.tween_property(self, "modulate:a", 0.0, 0.25)
	t.chain().tween_callback(func():
		visible = false
		scale = Vector2.ONE
		modulate.a = 1.0
		disabled = false
		callback.call()
	)

func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.12, 0.12, 0.95)
	sb.set_corner_radius_all(12)
	sb.set_border_width_all(3)
	sb.border_color = accent_color
	
	if is_pressed(): sb.bg_color = Color(0.25, 0.25, 0.25, 0.95)
	elif is_hovered(): sb.bg_color = Color(0.18, 0.18, 0.18, 0.95)
		
	draw_style_box(sb, rect)
	if not _font: return
	
	var icon_pos = Vector2(45, size.y/2)
	draw_circle(icon_pos, 28, accent_color)
	draw_circle(icon_pos, 24, Color(0.1, 0.1, 0.1))
	draw_string(_font, icon_pos + Vector2(-10, 10), "C", HORIZONTAL_ALIGNMENT_CENTER, -1, 28, accent_color)
	draw_string(_font, Vector2(90, size.y/2 + 10), "CONFIRM", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, accent_color)
