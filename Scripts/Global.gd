extends Node

# --- CONSTANTES GÉNÉRALES ---
const BASE_WIDTH = 1920
const BASE_HEIGHT = 1080
const SAVE_PATH = "user://highscore.dat"
const SETTINGS_PATH = "user://parameters.json"
const SECRET_SALT = "LILLIALES_SUPER_SECRET_SALT_KEY_2026_NO_CHEATING"

# --- SETTINGS DU JEU ---
var settings = {
	"SHAKE": true,
	"SPEED": "NORMAL",
	"RES_INDEX": 0,
	"MODE_INDEX": 0,
	"FPS_INDEX": 3,
	"LANGUAGE": "ENGLISH",
	"VOLUME": 0.3,
	"SFX_VOLUME": 0.5,
	"DIFFICULTY": "NORMAL"
}

# --- TRADUCTIONS (non-terminé) ---
const TRANSLATIONS = {
	"ENGLISH": {
		"play": "SOLO", "multiplayer": "MULTIPLAYER", "host": "HOST GAME", 
		"join": "JOIN GAME", "how_to": "HOW TO PLAY", "settings": "SETTINGS", 
		"quit": "QUIT", "back": "BACK", "menu": "MENU", "shake": "Screen Shake",
		"anim_speed": "Anim Speed", "res": "Resolution", "mode": "Mode",
		"lang": "Language: English", "fps": "Max FPS", "volume": "Music Volume",
		"sfx_volume": "SFX Volume", "difficulty": "Difficulty", "on": "ON",
		"off": "OFF", "normal": "NORMAL", "fast": "FAST",
		"Red": "Red", "Blue": "Blue", "Green": "Green", "Black": "Black", "White": "White",
	},
	"FRENCH": {
		"play": "SOLO", "multiplayer": "MULTIJOUEUR", "host": "HÉBERGER",
		"join": "REJOINDRE", "how_to": "COMMENT JOUER", "settings": "PARAMÈTRES",
		"quit": "QUITTER", "back": "RETOUR", "menu": "MENU", "shake": "Vibrations",
		"anim_speed": "Vitesse Anim", "res": "Résolution", "mode": "Mode",
		"lang": "Langue : Français", "fps": "FPS Max", "volume": "Volume Musique",
		"sfx_volume": "Volume Effets", "difficulty": "Difficulté", "on": "OUI",
		"off": "NON", "normal": "NORMALE", "fast": "RAPIDE",
		"Red": "Rouge", "Blue": "Bleu", "Green": "Vert", "Black": "Noir", "White": "Blanc",
	}
}

var current_highscore = 0

# --- HELPER POUR LA LOCALISATION ---
func get_text(key: String) -> String:
	var lang = settings["LANGUAGE"]
	if TRANSLATIONS.has(lang) and TRANSLATIONS[lang].has(key):
		return TRANSLATIONS[lang][key]
	return key

# --- ON SAVE ET ON LOAD ---
func save_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))

func load_settings():
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		var text = file.get_as_text()
		var json = JSON.new()
		if json.parse(text) == OK:
			var data = json.get_data()
			for k in data:
				if k in settings:
					settings[k] = data[k]

func _ready():
	load_settings()
	load_highscore()

func save_highscore(new_score: int):
	if new_score > current_highscore:
		current_highscore = new_score
		var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE)
		if file:
			file.store_string(str(current_highscore))

func load_highscore():
	if FileAccess.file_exists("user://highscore.dat"):
		var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
		var text = file.get_as_text()
		if text.is_valid_int():
			current_highscore = text.to_int()

func generate_hash(score: int) -> String:
	var data = str(score) + SECRET_SALT
	return data.sha256_text()
