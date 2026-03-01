extends Node

var DATABASE = [
	# PROGRESSION
	{"id": "FIRST_BLOOD", "is_rare": false, "name": {"ENGLISH": "First Blood", "FRENCH": "Premier Sang"}, "desc": {"ENGLISH": "Win your first game (Solo).", "FRENCH": "Gagnez votre première partie (Solo)."}, "hint": "Everyone remembers their first. Seek victory."},
	{"id": "APPRENTICE", "is_rare": false, "name": {"ENGLISH": "Apprentice", "FRENCH": "Apprenti"}, "desc": {"ENGLISH": "Win 5 games total.", "FRENCH": "Gagnez 5 parties au total."}, "hint": "Five steps on the golden path."},
	{"id": "ADEPT", "is_rare": false, "name": {"ENGLISH": "Adept", "FRENCH": "Adepte"}, "desc": {"ENGLISH": "Win 15 games total.", "FRENCH": "Gagnez 15 parties au total."}, "hint": "Fifteen victories. The mechanics are becoming second nature."},
	{"id": "LEGEND", "is_rare": true, "name": {"ENGLISH": "Lilliales Legend", "FRENCH": "Légende Lilliales"}, "desc": {"ENGLISH": "Win 25 games total.", "FRENCH": "Gagnez 25 parties au total."}, "hint": "Twenty-five victories. A true commitment."},
	{"id": "HUMBLE", "is_rare": false, "name": {"ENGLISH": "Humble Beginnings", "FRENCH": "Humbles Débuts"}, "desc": {"ENGLISH": "Lose a game for the first time.", "FRENCH": "Perdez une partie pour la première fois."}, "hint": "Even champions bleed. Taste your first defeat."},
	{"id": "IMPATIENT", "is_rare": false, "name": {"ENGLISH": "Impatient", "FRENCH": "Impatient"}, "desc": {"ENGLISH": "Click 15 times while waiting for your turn.", "FRENCH": "Cliquez 15 fois en attendant votre tour."}, "hint": "Patience is a virtue you clearly don't have."},
	
	# DIFFICULTÉ
	{"id": "DIFF_EASY", "is_rare": false, "name": {"ENGLISH": "Walk in the Park", "FRENCH": "Promenade de Santé"}, "desc": {"ENGLISH": "Win a game on Easy difficulty.", "FRENCH": "Gagnez en difficulté Facile."}, "hint": "A gentle stroll through the gardens."},
	{"id": "DIFF_MED", "is_rare": false, "name": {"ENGLISH": "Standard Issue", "FRENCH": "Standard"}, "desc": {"ENGLISH": "Win a game on Normal difficulty.", "FRENCH": "Gagnez en difficulté Normale."}, "hint": "Prove your worth in a fair fight."},
	{"id": "DIFF_HARD", "is_rare": false, "name": {"ENGLISH": "Hardened Warrior", "FRENCH": "Guerrier Endurci"}, "desc": {"ENGLISH": "Win a game on Hard difficulty.", "FRENCH": "Gagnez en difficulté Difficile."}, "hint": "Survive against relentless minds."},
	{"id": "DIFF_IMP", "is_rare": true, "name": {"ENGLISH": "God Slayer", "FRENCH": "Tueur de Dieu"}, "desc": {"ENGLISH": "Win a game on Impossible difficulty.", "FRENCH": "Gagnez en difficulté Impossible."}, "hint": "Only a fool challenges the impossible. Or a god."},

	# SCORE & PILES
	{"id": "CENTURION", "is_rare": true, "name": {"ENGLISH": "Centurion", "FRENCH": "Centurion"}, "desc": {"ENGLISH": "Reach 100 points or more.", "FRENCH": "Atteignez 100 points ou plus."}, "hint": "Greed is good. Break the triple digits."},
	{"id": "ABYSS", "is_rare": false, "name": {"ENGLISH": "Into the Abyss", "FRENCH": "Dans l'Abysse"}, "desc": {"ENGLISH": "Fall below 0 points.", "FRENCH": "Tombez sous 0 point."}, "hint": "How low can you go? Dive below zero."},
	{"id": "NEUTRAL", "is_rare": true, "name": {"ENGLISH": "True Neutral", "FRENCH": "Vrai Neutre"}, "desc": {"ENGLISH": "Finish with exactly 50 points and 0 tricks.", "FRENCH": "Finissez avec 50 points et 0 pli."}, "hint": "Perfect balance. 50 points, not a single trick."},
	{"id": "TRICKSTER", "is_rare": false, "name": {"ENGLISH": "Trickster", "FRENCH": "Filou"}, "desc": {"ENGLISH": "Finish with at least 5 tricks won.", "FRENCH": "Finissez avec au moins 5 plis gagnés."}, "hint": "Claim five victories on the board."},
	{"id": "SHARK", "is_rare": false, "name": {"ENGLISH": "Card Shark", "FRENCH": "As des Cartes"}, "desc": {"ENGLISH": "Finish with at least 10 tricks won.", "FRENCH": "Finissez avec au moins 10 plis gagnés."}, "hint": "Dominate the table. Take ten tricks."},
	{"id": "DOMINATION", "is_rare": true, "name": {"ENGLISH": "Total Domination", "FRENCH": "Domination Totale"}, "desc": {"ENGLISH": "Finish with at least 15 tricks won.", "FRENCH": "Finissez avec au moins 15 plis gagnés."}, "hint": "Leave them nothing. Take fifteen tricks."},
	{"id": "CLOSE", "is_rare": false, "name": {"ENGLISH": "Close Call", "FRENCH": "C'était Moins Une"}, "desc": {"ENGLISH": "Win with a final score of 54 or less.", "FRENCH": "Gagnez avec un score de 54 ou moins."}, "hint": "Derive the exact minimum value needed to survive. Win with a final score of 54 or less."},
	{"id": "PHOTO", "is_rare": true, "name": {"ENGLISH": "Photo Finish", "FRENCH": "Photo Finish"}, "desc": {"ENGLISH": "Win by exactly 1 point.", "FRENCH": "Gagnez avec exactement 1 point d'avance."}, "hint": "Adjust your settings to capture this split-second victory. Win by exactly 1 point."},
	{"id": "APEX", "is_rare": true, "name": {"ENGLISH": "Apex Predator", "FRENCH": "Superprédateur"}, "desc": {"ENGLISH": "Win vs 3 Impossible Bots by 30+ points.", "FRENCH": "Gagnez vs 3 Bots Impossibles de 30+ points."}, "hint": "Humiliate the highest minds by an absurd margin."},

	# AUTRES
	{"id": "TOXIC", "is_rare": false, "name": {"ENGLISH": "Toxic Gift", "FRENCH": "Cadeau Empoisonné"}, "desc": {"ENGLISH": "Force opponent to eat 2+ Lilies.", "FRENCH": "Forcez un adversaire à manger 2+ Lilies."}, "hint": "Force feed them the poison."},
	{"id": "STOMACH", "is_rare": false, "name": {"ENGLISH": "Iron Stomach", "FRENCH": "Estomac d'Acier"}, "desc": {"ENGLISH": "Win a trick with 3+ Lilies.", "FRENCH": "Gagnez un pli avec 3+ Lilies."}, "hint": "Consume the garden. Eat three Lilies at once."},
	{"id": "SABOTAGE", "is_rare": false, "name": {"ENGLISH": "Self-Sabotage", "FRENCH": "Auto-Sabotage"}, "desc": {"ENGLISH": "Play a Lily while leading the game.", "FRENCH": "Jouez une Lily en étant en tête."}, "hint": "Throw a Lily while wearing the crown."},
	{"id": "SNIPER", "is_rare": false, "name": {"ENGLISH": "Sniper", "FRENCH": "Sniper"}, "desc": {"ENGLISH": "Win a trick with a Rank 1 card.", "FRENCH": "Gagnez un pli avec une carte de Rang 1."}, "hint": "Strike true from the shadows. Win with a Rank 1."},
	{"id": "OVERKILL", "is_rare": false, "name": {"ENGLISH": "Overkill", "FRENCH": "Massacre"}, "desc": {"ENGLISH": "Beat a Rank 1 with a Rank 12.", "FRENCH": "Battez un Rang 1 avec un Rang 12."}, "hint": "Send them straight to the graveyard. Crush a Rank 1 with a Rank 12."},
	{"id": "POWER_TRIP", "is_rare": true, "name": {"ENGLISH": "Power Trip", "FRENCH": "Coup de Pouvoir"}, "desc": {"ENGLISH": "Beat a Power card with another Power card.", "FRENCH": "Battez un Atout avec un autre Atout."}, "hint": "Swing the momentum like a well-timed Pendulum Summon. Beat a Power card with another Power card."}
]

var unlocked = {}
var stats = {"wins": 0, "games": 0}
var save_path = "user://achievements.json"
var popup_layer: CanvasLayer

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK) 
	load_data()
	popup_layer = CanvasLayer.new()
	popup_layer.layer = 128
	add_child(popup_layer)

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var text = file.get_as_text()
		var json = JSON.new()
		if json.parse(text) == OK:
			var data = json.get_data()
			unlocked = data.get("unlocked", {})
			stats = data.get("stats", {"wins": 0, "games": 0})

func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"unlocked": unlocked, "stats": stats}))

func unlock(ach_id):
	if not unlocked.has(ach_id):
		unlocked[ach_id] = true
		save_data()
		_show_popup(ach_id)
		return true
	return false

func _show_popup(ach_id):
	var data = null
	for item in DATABASE:
		if item["id"] == ach_id:
			data = item
			break
	if not data: return
	var is_rare = data.get("is_rare", false)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(420, 110)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.08, 0.08, 0.95); sb.set_corner_radius_all(15); sb.set_border_width_all(3)
	sb.border_color = Color("FFD700") if not is_rare else Color(1.0, 0.5, 0.0)
	panel.add_theme_stylebox_override("panel", sb)
	
	var icon = AchievementIcon.new()
	icon.custom_minimum_size = Vector2(70, 70); icon.position = Vector2(20, 20)
	panel.add_child(icon); icon.set_data(ach_id, true, is_rare)
	
	var title = Label.new()
	title.text = "Legendary Achievement!" if is_rare else "Achievement Unlocked!"
	title.position = Vector2(105, 15); title.add_theme_color_override("font_color", sb.border_color)
	panel.add_child(title)
	
	var name_lbl = Label.new()
	name_lbl.text = data["name"]["ENGLISH"]; name_lbl.position = Vector2(105, 45); name_lbl.add_theme_font_size_override("font_size", 24)
	panel.add_child(name_lbl)
	
	popup_layer.add_child(panel)
	var screen_size = get_viewport().get_visible_rect().size
	panel.position = Vector2(screen_size.x + 20, screen_size.y - 140)
	
	if is_rare:
		var flash = ColorRect.new(); flash.set_anchors_preset(Control.PRESET_FULL_RECT); flash.color = Color(1, 0.8, 0.2, 0.4)
		popup_layer.add_child(flash); var ft = create_tween(); ft.tween_property(flash, "color:a", 0.0, 0.5); ft.tween_callback(flash.queue_free)
	
	var t = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "position:x", screen_size.x - 440, 0.6)
	t.tween_interval(4.0); t.tween_property(panel, "position:x", screen_size.x + 20, 0.5).set_ease(Tween.EASE_IN)
	t.tween_callback(panel.queue_free)
