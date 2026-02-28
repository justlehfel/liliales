extends Node

# --- DATABASE DES ACHIEVEMENTS DU JEU ORIGINEL ---
var DATABASE = [
	# PROGRESSION
	{"id": "FIRST_BLOOD", "name": {"ENGLISH": "First Blood", "FRENCH": "Premier Sang"}, "desc": {"ENGLISH": "Win your first game (Solo).", "FRENCH": "Gagnez votre première partie (Solo)."}, "icon_col": Color8(200, 200, 200)},
	{"id": "APPRENTICE", "name": {"ENGLISH": "Apprentice", "FRENCH": "Apprenti"}, "desc": {"ENGLISH": "Win 5 games total.", "FRENCH": "Gagnez 5 parties au total."}, "icon_col": Color8(100, 255, 100)},
	{"id": "ADEPT", "name": {"ENGLISH": "Adept", "FRENCH": "Adepte"}, "desc": {"ENGLISH": "Win 15 games total.", "FRENCH": "Gagnez 15 parties au total."}, "icon_col": Color8(50, 200, 50)},
	{"id": "LEGEND", "name": {"ENGLISH": "Lilliales Legend", "FRENCH": "Légende Lilliales"}, "desc": {"ENGLISH": "Win 25 games total.", "FRENCH": "Gagnez 25 parties au total."}, "icon_col": Color8(0, 150, 0)},
	{"id": "HUMBLE", "name": {"ENGLISH": "Humble Beginnings", "FRENCH": "Humbles Débuts"}, "desc": {"ENGLISH": "Lose a game for the first time.", "FRENCH": "Perdez une partie pour la première fois."}, "icon_col": Color8(150, 50, 50)},
	
	# DIFFICULTÉ
	{"id": "DIFF_EASY", "name": {"ENGLISH": "Walk in the Park", "FRENCH": "Promenade de Santé"}, "desc": {"ENGLISH": "Win a game on Easy difficulty.", "FRENCH": "Gagnez en difficulté Facile."}, "icon_col": Color8(100, 255, 100)},
	{"id": "DIFF_MED", "name": {"ENGLISH": "Standard Issue", "FRENCH": "Standard"}, "desc": {"ENGLISH": "Win a game on Normal difficulty.", "FRENCH": "Gagnez en difficulté Normale."}, "icon_col": Color8(255, 255, 100)},
	{"id": "DIFF_HARD", "name": {"ENGLISH": "Hardened Warrior", "FRENCH": "Guerrier Endurci"}, "desc": {"ENGLISH": "Win a game on Hard difficulty.", "FRENCH": "Gagnez en difficulté Difficile."}, "icon_col": Color8(255, 100, 50)},
	{"id": "DIFF_IMP", "name": {"ENGLISH": "God Slayer", "FRENCH": "Tueur de Dieu"}, "desc": {"ENGLISH": "Win a game on Impossible difficulty.", "FRENCH": "Gagnez en difficulté Impossible."}, "icon_col": Color8(255, 0, 255)},

	# SCORE & PILES
	{"id": "CENTURION", "name": {"ENGLISH": "Centurion", "FRENCH": "Centurion"}, "desc": {"ENGLISH": "Reach 100 points or more.", "FRENCH": "Atteignez 100 points ou plus."}, "icon_col": Color8(255, 215, 0)},
	{"id": "ABYSS", "name": {"ENGLISH": "Into the Abyss", "FRENCH": "Dans l'Abysse"}, "desc": {"ENGLISH": "Fall below 0 points.", "FRENCH": "Tombez sous 0 point."}, "icon_col": Color8(50, 0, 50)},
	{"id": "NEUTRAL", "name": {"ENGLISH": "True Neutral", "FRENCH": "Vrai Neutre"}, "desc": {"ENGLISH": "Finish with exactly 50 points and 0 tricks.", "FRENCH": "Finissez avec 50 points et 0 pli."}, "icon_col": Color8(150, 150, 150)},
	{"id": "TRICKSTER", "name": {"ENGLISH": "Trickster", "FRENCH": "Filou"}, "desc": {"ENGLISH": "Finish with at least 5 tricks won.", "FRENCH": "Finissez avec au moins 5 plis gagnés."}, "icon_col": Color8(200, 200, 255)},
	{"id": "SHARK", "name": {"ENGLISH": "Card Shark", "FRENCH": "As des Cartes"}, "desc": {"ENGLISH": "Finish with at least 10 tricks won.", "FRENCH": "Finissez avec au moins 10 plis gagnés."}, "icon_col": Color8(100, 100, 255)},
	{"id": "DOMINATION", "name": {"ENGLISH": "Total Domination", "FRENCH": "Domination Totale"}, "desc": {"ENGLISH": "Finish with at least 15 tricks won.", "FRENCH": "Finissez avec au moins 15 plis gagnés."}, "icon_col": Color8(0, 0, 255)},
	{"id": "CLOSE", "name": {"ENGLISH": "Close Call", "FRENCH": "C'était Moins Une"}, "desc": {"ENGLISH": "Win with a final score of 54 or less.", "FRENCH": "Gagnez avec un score de 54 ou moins."}, "icon_col": Color8(200, 100, 100)},
	{"id": "PHOTO", "name": {"ENGLISH": "Photo Finish", "FRENCH": "Photo Finish"}, "desc": {"ENGLISH": "Win by exactly 1 point.", "FRENCH": "Gagnez avec exactement 1 point d'avance."}, "icon_col": Color8(255, 255, 255)},
	{"id": "APEX", "name": {"ENGLISH": "Apex Predator", "FRENCH": "Superprédateur"}, "desc": {"ENGLISH": "Win vs 3 Impossible Bots by 30+ points.", "FRENCH": "Gagnez vs 3 Bots Impossibles de 30+ points."}, "icon_col": Color8(255, 0, 0)},

	# AUTRES
	{"id": "TOXIC", "name": {"ENGLISH": "Toxic Gift", "FRENCH": "Cadeau Empoisonné"}, "desc": {"ENGLISH": "Force opponent to eat 2+ Lilies.", "FRENCH": "Forcez un adversaire à manger 2+ Lilies."}, "icon_col": Color8(100, 200, 100)},
	{"id": "STOMACH", "name": {"ENGLISH": "Iron Stomach", "FRENCH": "Estomac d'Acier"}, "desc": {"ENGLISH": "Win a trick with 3+ Lilies.", "FRENCH": "Gagnez un pli avec 3+ Lilies."}, "icon_col": Color8(150, 100, 50)},
	{"id": "SABOTAGE", "name": {"ENGLISH": "Self-Sabotage", "FRENCH": "Auto-Sabotage"}, "desc": {"ENGLISH": "Play a Lily while leading the game.", "FRENCH": "Jouez une Lily en étant en tête."}, "icon_col": Color8(255, 100, 100)},
	{"id": "SNIPER", "name": {"ENGLISH": "Sniper", "FRENCH": "Sniper"}, "desc": {"ENGLISH": "Win a trick with a Rank 1 card.", "FRENCH": "Gagnez un pli avec une carte de Rang 1."}, "icon_col": Color8(200, 200, 200)},
	{"id": "OVERKILL", "name": {"ENGLISH": "Overkill", "FRENCH": "Massacre"}, "desc": {"ENGLISH": "Beat a Rank 1 with a Rank 12.", "FRENCH": "Battez un Rang 1 avec un Rang 12."}, "icon_col": Color8(255, 50, 50)},
	{"id": "OUCH", "name": {"ENGLISH": "Ouch!", "FRENCH": "Aïe !"}, "desc": {"ENGLISH": "Eat a Lily for the first time.", "FRENCH": "Mangez une Lily pour la première fois."}, "icon_col": Color8(200, 50, 50)},
	{"id": "POWER_TRIP", "name": {"ENGLISH": "Power Trip", "FRENCH": "Coup de Pouvoir"}, "desc": {"ENGLISH": "Beat a Power card with another Power card.", "FRENCH": "Battez un Atout avec un autre Atout."}, "icon_col": Color8(255, 255, 255)},
	{"id": "DRAFT_MASTER", "name": {"ENGLISH": "Draft Master", "FRENCH": "Maître de la Pioche"}, "desc": {"ENGLISH": "Draft 3 cards of same suit in one go.", "FRENCH": "Piochez 3 cartes de même couleur d'un coup."}, "icon_col": Color8(200, 200, 255)},
	{"id": "HIGH_HOPES", "name": {"ENGLISH": "High Hopes", "FRENCH": "Grands Espoirs"}, "desc": {"ENGLISH": "Draft a Rank 12 card.", "FRENCH": "Piochez une carte de Rang 12."}, "icon_col": Color8(255, 215, 0)},
	{"id": "LOW_PROFILE", "name": {"ENGLISH": "Low Profile", "FRENCH": "Profil Bas"}, "desc": {"ENGLISH": "Draft a Rank 1 card.", "FRENCH": "Piochez une carte de Rang 1."}, "icon_col": Color8(150, 150, 150)},
	{"id": "FIRST_SPARK", "name": {"ENGLISH": "First Spark", "FRENCH": "Première Étincelle"}, "desc": {"ENGLISH": "Play a Power Card.", "FRENCH": "Jouez une carte de Pouvoir."}, "icon_col": Color8(255, 255, 200)}
]

var unlocked = {}
var stats = {"wins": 0, "games": 0}
var save_path = "user://achievements.json"

# Tracker de temps de jeu
var lilies_eaten_total = 0

func _ready():
	load_data()

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
	if data:
		print("ACHIEVEMENT UNLOCKED: ", data["name"]["ENGLISH"])
		# Normalement je mettrais un nouveau popup dans l'UI
		# Mais pour l'instant sachant que j'ai la flemme je vais juste jouer un bruit... éventuellement
		var sm = get_tree().root.find_child("SoundManager", true, false)
		if sm: sm.play_sfx("achievement")
