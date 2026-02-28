extends Node

@onready var music_player = $MusicPlayer

var music_tracks: Array[String] = []
var current_track_index = -1
var sfx_library = {}

func _ready():
	# Je scan pour la musique
	scan_music("res://Assets/Music/")
	
	# Je load les SFX
	load_sfx("res://Assets/SFX/")
	
	# Je connecte le signal
	music_player.finished.connect(_on_music_finished)
	
	# Je start la musique
	play_next_music()

func scan_music(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and (file_name.ends_with(".mp3") or file_name.ends_with(".ogg")):
				music_tracks.append(path + file_name)
			file_name = dir.get_next()
	
	if music_tracks.size() > 0:
		music_tracks.shuffle()

func play_next_music():
	if music_tracks.is_empty(): return
	
	# Je prends quelque chose de random
	var new_track = music_tracks.pick_random()
	if music_tracks.size() > 1:
		while new_track == music_player.stream.resource_path if music_player.stream else "":
			new_track = music_tracks.pick_random()
			
	var stream = load(new_track)
	music_player.stream = stream
	update_volume()
	music_player.play()

func skip_song():
	play_next_music()

func update_volume():
	# J'utilise les trucs-choses décibels de Godot à la place
	var vol_linear = Global.settings["VOLUME"] * 0.6
	music_player.volume_db = linear_to_db(vol_linear)

func _on_music_finished():
	play_next_music()

# --- MANAGER DES SFX ---
func load_sfx(path: String):
	var sfx_files = {
		"whoosh": "whoosh-card.mp3",
		"lilytrick": "lilytrick.mp3",
		"wintrick": "wintrick.mp3",
		"loosetrick": "loosetrick.mp3",
		"start": "start-of-the-game.mp3",
		"turn": "turning-cards.mp3",
		"pickup": "pickup.mp3",
		"impact": "impact.mp3",
		"click": "click.mp3",
		"achievement": "achievement.mp3"
	}
	
	for key in sfx_files:
		if FileAccess.file_exists(path + sfx_files[key]):
			sfx_library[key] = load(path + sfx_files[key])

func play_sfx(sfx_name: String):
	if sfx_library.has(sfx_name):
		# Je crée un nouveau joueur qui joue les sons
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = sfx_library[sfx_name]
		player.volume_db = linear_to_db(Global.settings["SFX_VOLUME"])
		player.finished.connect(player.queue_free)
		player.play()

func update_sfx_volume():
	# Cela affecte juste les nouveaux sons
	pass
