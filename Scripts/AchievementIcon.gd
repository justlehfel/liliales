extends Control
class_name AchievementIcon

var achievement_id: String = ""
var is_unlocked: bool = false
var is_rare: bool = false

func set_data(id: String, unlocked: bool, rare: bool):
	achievement_id = id
	is_unlocked = unlocked
	is_rare = rare
	queue_redraw()

func _draw():
	var w = size.x
	var h = size.y
	var center = Vector2(w / 2.0, h / 2.0)

	# --- CARTES PAS DÉBLOQUÉES ---
	if not is_unlocked:
		var c_dim = Color(0.2, 0.2, 0.2)
		draw_circle(center, w * 0.35, Color(0.08, 0.08, 0.08))
		draw_arc(center, w * 0.35, 0, TAU, 32, c_dim, 2.0)
		# Le point d'interrogation
		draw_arc(center - Vector2(0, h * 0.05), w * 0.12, PI, PI * 2.2, 16, c_dim, 3.0)
		draw_line(center + Vector2(w * 0.1, -h * 0.02), center + Vector2(0, h * 0.1), c_dim, 3.0)
		draw_circle(center + Vector2(0, h * 0.2), 3.0, c_dim)
		return

	# --- CARTES DÉBLOQUÉES ---
	var base_gold = Color("FFD700")
	var rare_gold = Color(1.0, 0.5, 0.0)
	var primary = rare_gold if is_rare else base_gold

	match achievement_id:
		"IMPATIENT":
			var c = Color(1.0, 0.4, 0.4)
			draw_arc(center, w * 0.3, 0, TAU, 32, c, 3.0)
			draw_line(center, center + Vector2(0, -h * 0.2), c, 3.0) 
			draw_line(center, center + Vector2(w * 0.15, 0), c, 2.0) 
			draw_arc(center + Vector2(w*0.35, -h*0.1), w*0.1, -0.5, 0.5, 8, c, 2.0)
			draw_arc(center - Vector2(w*0.35, h*0.1), w*0.1, PI-0.5, PI+0.5, 8, c, 2.0)

		"FIRST_BLOOD":
			var c = Color(0.8, 0.1, 0.1)
			draw_circle(center + Vector2(0, h * 0.1), w * 0.15, c)
			draw_polygon(PackedVector2Array([center + Vector2(-w * 0.15, h * 0.1), center + Vector2(w * 0.15, h * 0.1), center - Vector2(0, h * 0.25)]), PackedColorArray([c, c, c]))
		"APPRENTICE":
			var c = Color(0.4, 0.8, 1.0)
			draw_polygon(PackedVector2Array([center - Vector2(0, h*0.25), center + Vector2(w*0.15, 0), center + Vector2(0, h*0.25), center - Vector2(w*0.15, 0)]), PackedColorArray([c, c, c, c]))
		"ADEPT":
			var c = Color(0.2, 0.6, 1.0)
			draw_polygon(PackedVector2Array([center - Vector2(w*0.25, h*0.2), center + Vector2(w*0.25, h*0.2), center + Vector2(w*0.2, h*0.15), center + Vector2(0, h*0.35), center - Vector2(w*0.2, h*0.15)]), PackedColorArray([c, c, c, c, c]))
		"LEGEND":
			var points = PackedVector2Array()
			var colors = PackedColorArray()
			for i in range(10):
				var r = w * 0.4 if i % 2 == 0 else w * 0.15
				var angle = i * (TAU / 10.0) - (PI / 2.0)
				points.append(center + Vector2(cos(angle), sin(angle)) * r)
				colors.append(primary)
			draw_polygon(points, colors)
		"HUMBLE":
			var c = Color(0.4, 0.4, 0.5)
			draw_circle(center + Vector2(0, h * 0.1), w * 0.15, c)
			draw_polygon(PackedVector2Array([center + Vector2(-w * 0.15, h * 0.1), center + Vector2(w * 0.15, h * 0.1), center - Vector2(0, h * 0.25)]), PackedColorArray([c, c, c]))
			draw_line(center - Vector2(w*0.1, h*0.1), center + Vector2(w*0.1, h*0.3), Color(0.08, 0.08, 0.08), 3.0) 
		"DIFF_EASY":
			var c = Color(0.3, 0.8, 0.3)
			draw_polygon(PackedVector2Array([center - Vector2(0, h*0.3), center + Vector2(w*0.2, 0), center + Vector2(0, h*0.3), center - Vector2(w*0.2, 0)]), PackedColorArray([c, c, c, c]))
			draw_line(center - Vector2(0, h*0.2), center + Vector2(0, h*0.3), Color(0.1, 0.5, 0.1), 2.0)
		"DIFF_MED":
			var c = Color(0.8, 0.8, 0.8)
			draw_line(center - Vector2(w*0.25, h*0.25), center + Vector2(w*0.25, h*0.25), c, 4.0)
			draw_line(center - Vector2(w*0.25, -h*0.25), center + Vector2(w*0.25, -h*0.25), c, 4.0)
		"DIFF_HARD":
			var c = Color(0.8, 0.2, 0.2)
			draw_circle(center - Vector2(0, h*0.1), w*0.2, c)
			draw_rect(Rect2(center.x - w*0.1, center.y, w*0.2, h*0.2), c)
			draw_circle(center - Vector2(w*0.08, h*0.1), w*0.05, Color.BLACK)
			draw_circle(center + Vector2(w*0.08, -h*0.1), w*0.05, Color.BLACK)
		"DIFF_IMP":
			var c = Color(0.9, 0.1, 0.9)
			draw_polygon(PackedVector2Array([center - Vector2(w*0.3, -h*0.2), center - Vector2(w*0.3, h*0.2), center - Vector2(w*0.1, 0), center, center - Vector2(0, h*0.3), center + Vector2(w*0.1, 0), center + Vector2(w*0.3, h*0.2), center + Vector2(w*0.3, -h*0.2)]), PackedColorArray([c, c, c, c, c, c, c, c]))
		"CENTURION":
			draw_arc(center, w * 0.3, PI * 0.25, PI * 1.75, 32, primary, 8.0)
			draw_line(center - Vector2(0, h*0.4), center - Vector2(0, h*0.2), primary, 4.0)
			draw_line(center + Vector2(0, h*0.2), center + Vector2(0, h*0.4), primary, 4.0)
		"ABYSS":
			var c = Color(0.3, 0.0, 0.4)
			draw_rect(Rect2(center.x - w * 0.2, center.y - h * 0.3, w * 0.4, h * 0.4), c)
			draw_polygon(PackedVector2Array([center - Vector2(w * 0.4, -h * 0.1), center + Vector2(w * 0.4, -h * 0.1), center + Vector2(0, h * 0.4)]), PackedColorArray([c, c, c]))
		"NEUTRAL":
			var c = Color(0.6, 0.6, 0.6)
			draw_arc(center, w*0.3, 0, TAU, 32, c, 3.0)
			draw_line(center - Vector2(0, h*0.3), center + Vector2(0, h*0.3), c, 3.0)
			draw_circle(center - Vector2(w*0.15, 0), w*0.08, c)
			draw_arc(center + Vector2(w*0.15, 0), w*0.08, 0, TAU, 16, c, 2.0)
		"TRICKSTER":
			var c = Color(0.4, 0.4, 0.9)
			draw_polygon(PackedVector2Array([center + Vector2(0, h*0.2), center - Vector2(w*0.25, -h*0.1), center - Vector2(w*0.15, h*0.25), center, center + Vector2(w*0.15, h*0.25), center + Vector2(w*0.25, -h*0.1)]), PackedColorArray([c, c, c, c, c, c]))
		"SHARK":
			var c = Color(0.2, 0.4, 0.8)
			draw_polygon(PackedVector2Array([center + Vector2(-w*0.2, h*0.2), center + Vector2(w*0.3, h*0.2), center + Vector2(0, -h*0.3), center - Vector2(w*0.1, -h*0.1)]), PackedColorArray([c, c, c, c]))
			draw_line(center - Vector2(w*0.4, h*0.2), center + Vector2(w*0.4, h*0.2), Color(0.1, 0.3, 0.9), 4.0)
		"DOMINATION":
			draw_polygon(PackedVector2Array([center - Vector2(w*0.3, -h*0.2), center - Vector2(w*0.35, h*0.2), center - Vector2(w*0.15, 0), center + Vector2(0, h*0.3), center + Vector2(w*0.15, 0), center + Vector2(w*0.35, h*0.2), center + Vector2(w*0.3, -h*0.2)]), PackedColorArray([primary, primary, primary, primary, primary, primary, primary]))
		"CLOSE":
			var c = Color(0.8, 0.4, 0.4)
			draw_arc(center + Vector2(0, h * 0.4), w * 0.6, PI * 1.2, PI * 1.8, 32, Color(0.4, 0.4, 0.4), 2.0)
			draw_line(center - Vector2(w * 0.3, h * 0.2), center + Vector2(w * 0.3, h * 0.2), c, 3.0)
			draw_circle(center, 4.0, Color.WHITE)
		"PHOTO":
			var c = Color.WHITE
			draw_circle(center, w * 0.35, Color(0.05, 0.05, 0.05))
			draw_arc(center, w * 0.35, 0, TAU, 32, c, 3.0)
			draw_circle(center, w * 0.15, Color.BLACK)
			for i in range(6):
				var angle = i * (TAU / 6.0)
				var p1 = center + Vector2(cos(angle), sin(angle)) * (w * 0.15)
				var p2 = center + Vector2(cos(angle + 1.2), sin(angle + 1.2)) * (w * 0.35)
				draw_line(p1, p2, c, 2.0)
		"APEX":
			var c = Color(0.9, 0.1, 0.1)
			draw_polygon(PackedVector2Array([center - Vector2(w*0.3, -h*0.3), center + Vector2(w*0.3, -h*0.3), center - Vector2(0, h*0.4)]), PackedColorArray([c, c, c]))
			draw_circle(center + Vector2(0, h*0.1), w*0.08, Color.BLACK)
			draw_circle(center + Vector2(0, h*0.1), w*0.03, primary)
		"TOXIC":
			var c = Color(0.2, 0.8, 0.2)
			draw_circle(center - Vector2(0, h * 0.1), w * 0.15, c)
			draw_circle(center + Vector2(w * 0.15, h * 0.15), w * 0.12, c)
			draw_circle(center + Vector2(-w * 0.15, h * 0.15), w * 0.12, c)
		"STOMACH":
			var c = Color(0.6, 0.4, 0.2)
			draw_circle(center, w*0.25, c)
			draw_circle(center, w*0.15, Color(0.08, 0.08, 0.08))
			for i in range(8):
				var angle = i * (TAU / 8.0)
				draw_circle(center + Vector2(cos(angle), sin(angle)) * (w * 0.3), w*0.05, c)
		"SABOTAGE":
			var c = Color(0.8, 0.2, 0.2)
			draw_polygon(PackedVector2Array([center - Vector2(w*0.1, -h*0.3), center + Vector2(w*0.1, -h*0.3), center + Vector2(0, h*0.1)]), PackedColorArray([c, c, c]))
			draw_line(center - Vector2(w*0.3, h*0.2), center + Vector2(w*0.3, h*0.2), Color.WHITE, 3.0) 
		"SNIPER":
			var c = Color(0.7, 0.7, 0.7)
			draw_arc(center, w*0.3, 0, TAU, 32, c, 2.0)
			draw_line(center - Vector2(w*0.4, 0), center - Vector2(w*0.1, 0), c, 2.0)
			draw_line(center + Vector2(w*0.4, 0), center + Vector2(w*0.1, 0), c, 2.0)
			draw_line(center - Vector2(0, h*0.4), center - Vector2(0, h*0.1), c, 2.0)
			draw_line(center + Vector2(0, h*0.4), center + Vector2(0, h*0.1), c, 2.0)
			draw_circle(center, 3.0, Color.RED)
		"OVERKILL":
			var c = Color(0.9, 0.3, 0.3)
			draw_rect(Rect2(center.x - w*0.3, center.y - h*0.2, w*0.6, h*0.3), c)
			draw_rect(Rect2(center.x - w*0.4, center.y + h*0.1, w*0.8, h*0.2), c)
			draw_line(center - Vector2(0, h*0.4), center - Vector2(0, h*0.2), Color.WHITE, 3.0) 
		"POWER_TRIP":
			var c = Color(0.8, 0.9, 1.0)
			var anchor = center - Vector2(0, h * 0.4)
			var pend_center = center + Vector2(w * 0.25, h * 0.15)
			draw_line(anchor, pend_center, Color(0.5, 0.5, 0.5), 2.0)
			draw_polygon(PackedVector2Array([
				pend_center - Vector2(0, h * 0.15), pend_center + Vector2(w * 0.1, 0),
				pend_center + Vector2(0, h * 0.15), pend_center - Vector2(w * 0.1, 0)
			]), PackedColorArray([c, c, c, c]))
			draw_circle(anchor, 4.0, primary)

		_: 
			draw_polygon(PackedVector2Array([
				center - Vector2(0, h * 0.3), center + Vector2(w * 0.2, 0),
				center + Vector2(0, h * 0.3), center - Vector2(w * 0.2, 0)
			]), PackedColorArray([primary, primary, primary, primary]))
