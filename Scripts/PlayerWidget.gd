extends Control

var p_name: String = "Bot"
var score: int = 50
var hand_count: int = 0
var accent_color: Color = Color.WHITE
var _font: SystemFont

func _ready():
	custom_minimum_size = Vector2(200, 100)
	size = custom_minimum_size
	
	if has_node("Icon"): $Icon.visible = false
	
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Arial", "Segoe UI", "Sans-Serif"])
	_font.font_weight = 700

func setup(_name, _score, _col):
	p_name = _name; score = _score; accent_color = _col
	queue_redraw()

func update_score(new_score):
	if new_score != score:
		var diff = new_score - score
		var txt = ("+" if diff > 0 else "") + str(diff)
		var col = Color.GREEN if diff > 0 else Color.RED
		_spawn_float_text(txt, col)
	score = new_score
	queue_redraw()

func update_hand(count):
	hand_count = count; queue_redraw()

func _spawn_float_text(txt, col):
	var ft = FloatingText.new()
	add_child(ft)
	ft.setup(size/2 + Vector2(0, -50), txt, col)

func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.12, 0.12, 0.95)
	sb.set_corner_radius_all(10); sb.set_border_width_all(2); sb.border_color = accent_color
	draw_style_box(sb, rect)
	
	if not _font: return
	
	# Icône
	var ip = Vector2(45, size.y/2)
	draw_circle(ip, 28, accent_color)
	draw_circle(ip, 24, Color(0.1, 0.1, 0.1))
	draw_string(_font, ip + Vector2(-8, 10), p_name.left(1), HORIZONTAL_ALIGNMENT_CENTER, -1, 28, accent_color)
	
	# Info
	draw_string(_font, Vector2(90, 35), p_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, accent_color)
	draw_string(_font, Vector2(90, 65), "Score: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	
	# Cartes
	if hand_count > 0:
		var cp = Vector2(size.x - 20, 20)
		draw_circle(cp, 14, Color("DC2828"))
		draw_string(_font, cp + Vector2(-6, 5), str(hand_count), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.WHITE)
