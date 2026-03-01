extends Node

const NUM_PLAYERS = 4
const RANKS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
const LILY_RANK = 8

@onready var card_scene = preload("res://Scenes/Card.tscn")
@onready var card_container = $"../CardContainer"
@onready var trick_center = $"../TrickCenter"
@onready var ui_message_label = $"../UI/MessageBox/Label"
@onready var confirm_btn = $"../UI/ConfirmButton"

@onready var p_widget_top = $"../UI/PlayerTop"
@onready var p_widget_left = $"../UI/PlayerLeft"
@onready var p_widget_right = $"../UI/PlayerRight"
@onready var my_stats_labels = [$"../UI/MyStatsBox/Name", $"../UI/MyStatsBox/Score", $"../UI/MyStatsBox/Tricks"]
@onready var round_label = $"../UI/RoundInfoBox/RoundLabel"
@onready var suit_container = $"../UI/RoundInfoBox/SuitContainer"

@onready var sound_manager = get_node_or_null("../SoundManager")

var round_num = 1
var players: Array[PlayerData] = []
var active_suits = []
var available_suits = []
var deck = []
var turn_idx = 0 
var trick_pile = [] 
var cards_to_pick = 1
var current_draft_step = 0
var impatient_clicks = 0
var is_exit_popup_open = false

enum Phase { DRAFTING, PLAYING, RESOLVING }
var current_phase = Phase.DRAFTING
var bot_colors = [Color.CYAN, Color.MAGENTA, Color.ORANGE]

var msg_box_sb: StyleBoxFlat
var screen_pulse_sb: StyleBoxFlat
var current_trick_dominant_suit = "" 
var cheat_seq: int = 0 

func _ready():
	if p_widget_left:
		p_widget_left.set_anchors_preset(Control.PRESET_TOP_LEFT)
		p_widget_left.position = Vector2(140, 540) 
	
	confirm_btn.pressed.connect(_on_confirm_pressed)
	_init_players()
	_setup_dynamic_ui()
	
	if not Global.settings.has("DIFFICULTY"): Global.settings["DIFFICULTY"] = "NORMAL"
	_reset_game_logic()
	start_round_setup()

func _input(event):
	if is_exit_popup_open: return

	if event is InputEventKey and event.pressed and not event.echo:
		# --- MENU ÉCHAP ---
		if event.keycode == KEY_ESCAPE:
			_show_exit_confirmation()
			return

		if event.keycode == KEY_UP:
			cheat_seq += 1
			if cheat_seq >= 3:
				cheat_seq = 0
				_activate_cheat()
		else:
			cheat_seq = 0

func _show_exit_confirmation():
	is_exit_popup_open = true
	var ui = $"../UI"
	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(overlay)
	
	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.7)
	overlay.add_child(dim)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 300)
	panel.position = (Vector2(1920, 1080) - panel.custom_minimum_size) / 2.0
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.0, 0.02, 0.95)
	sb.border_color = Color("FFD700")
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(20)
	panel.add_theme_stylebox_override("panel", sb)
	overlay.add_child(panel)
	
	var lbl = Label.new()
	lbl.text = "Abandon the game?\n(Back to Menu)"
	lbl.add_theme_font_size_override("font_size", 38)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(0, 50)
	lbl.custom_minimum_size = Vector2(600, 100)
	panel.add_child(lbl)
	
	var hbox = HBoxContainer.new()
	hbox.position = Vector2(0, 180)
	hbox.custom_minimum_size = Vector2(600, 80)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 50)
	panel.add_child(hbox)
	
	var btn_yes = Button.new(); btn_yes.text = "YES"; btn_yes.custom_minimum_size = Vector2(180, 60)
	var btn_no = Button.new(); btn_no.text = "NO"; btn_no.custom_minimum_size = Vector2(180, 60)
	
	for b in [btn_yes, btn_no]:
		var bsb = StyleBoxFlat.new()
		bsb.bg_color = Color(0.2, 0.2, 0.2, 1.0); bsb.set_corner_radius_all(10); bsb.set_border_width_all(2); bsb.border_color = Color.WHITE
		b.add_theme_stylebox_override("normal", bsb)
		hbox.add_child(b)
	
	btn_no.pressed.connect(func():
		is_exit_popup_open = false
		overlay.queue_free()
	)
	
	btn_yes.pressed.connect(func():
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	)
	
	panel.scale = Vector2.ZERO
	create_tween().tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _activate_cheat():
	round_num = 5
	while available_suits.size() > 0:
		active_suits.append(available_suits.pop_back())
	for p in players:
		p.hand.clear()
		p.draft_hand.clear()
	for c in trick_pile: 
		if is_instance_valid(c.node): c.node.queue_free()
	trick_pile.clear()
	for c in card_container.get_children(): 
		if is_instance_valid(c): c.queue_free()
	confirm_btn.visible = false
	start_round_setup()

func _setup_dynamic_ui():
	var box_paths = ["../UI/MessageBox", "../UI/MyStatsBox", "../UI/RoundInfoBox"]
	for path in box_paths:
		var node = get_node_or_null(path)
		if node and (node is PanelContainer or node is Panel):
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color(0.12, 0.12, 0.12, 0.95)
			sb.set_corner_radius_all(15)
			sb.set_border_width_all(4)
			sb.border_color = Color.WHITE
			node.add_theme_stylebox_override("panel", sb)
			if "MessageBox" in path: msg_box_sb = sb

	screen_pulse_sb = StyleBoxFlat.new()
	screen_pulse_sb.bg_color = Color.TRANSPARENT
	screen_pulse_sb.border_color = Color(1.0, 0.8, 0.0, 0.0) 
	screen_pulse_sb.set_border_width_all(15)
	
	var pulse_panel = Panel.new()
	pulse_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	pulse_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pulse_panel.add_theme_stylebox_override("panel", screen_pulse_sb)
	pulse_panel.z_index = 50 
	$"../UI".add_child(pulse_panel)

func _process(_delta):
	if current_phase == Phase.PLAYING and turn_idx == 0:
		var pulse_alpha = (sin(Time.get_ticks_msec() / 300.0) + 1.0) * 0.08 
		screen_pulse_sb.border_color = Color(1.0, 0.8, 0.0, pulse_alpha)
	else:
		if screen_pulse_sb: screen_pulse_sb.border_color = Color.TRANSPARENT
		
	if msg_box_sb:
		if current_phase != Phase.DRAFTING and current_trick_dominant_suit != "":
			if current_trick_dominant_suit == "Joker":
				var p = (sin(Time.get_ticks_msec() / 150.0) + 1.0) * 0.5
				msg_box_sb.border_color = Color(p, p, p, 1.0)
			else:
				msg_box_sb.border_color = _get_suit_color(current_trick_dominant_suit)
		else:
			msg_box_sb.border_color = Color.WHITE

func _init_players():
	players.clear()
	var p_name = Global.settings.get("PLAYER_NAME", "You")
	players.append(PlayerData.new(p_name, false, 0))
	var bot_names = ["Félix", "Émerik", "Thomas", "Adam", "Diego", "Simon"]
	bot_names.shuffle()
	var widgets = [null, p_widget_left, p_widget_top, p_widget_right]
	for i in range(1, NUM_PLAYERS):
		players.append(PlayerData.new(bot_names[i-1], true, i))
		if widgets[i]: widgets[i].setup(players[i].name, 50, bot_colors[i-1])
	my_stats_labels[0].text = players[0].name

func _reset_game_logic():
	for p in players:
		p.score = 50
		p.tricks_won = 0
	
	if AchievementManager: 
		AchievementManager.stats["games"] += 1
		AchievementManager.save_data()

	var colors = ["Red", "Blue", "Green"]
	var powers = ["Black", "White"]
	var first = colors.pick_random()
	available_suits = []
	for c in colors: 
		if c != first: available_suits.append(c)
	available_suits.append_array(powers)
	available_suits.shuffle()
	active_suits = [first]
	round_num = 1
	_update_all_ui()

func start_round_setup():
	current_trick_dominant_suit = "" 
	impatient_clicks = 0
	if round_num > 1 and available_suits.size() > 0:
		active_suits.append(available_suits.pop_back())
	deck.clear()
	for s in active_suits:
		for r in RANKS:
			deck.append({"suit": s, "rank": r})
	deck.shuffle()
	if Global.settings["DIFFICULTY"] == "IMPOSSIBLE":
		deck.sort_custom(func(a, b): 
			var val_a = a.rank + (100 if a.suit in ["Black","White"] else 0)
			var val_b = b.rank + (100 if b.suit in ["Black","White"] else 0)
			return val_a < val_b 
		)
	for p in players:
		p.draft_hand.clear()
		p.hand.clear()
	var cards_per_pack = round_num * 3 
	for _i in range(cards_per_pack):
		for p in players:
			if deck.size() > 0: p.draft_hand.append(deck.pop_back())
	current_phase = Phase.DRAFTING
	cards_to_pick = round_num
	current_draft_step = 0
	_update_all_ui()
	_render_human_draft_hand(true)

func _update_all_ui():
	my_stats_labels[1].text = "Score: %d" % players[0].score
	my_stats_labels[2].text = "Tricks: %d" % players[0].tricks_won
	var widgets = [null, p_widget_left, p_widget_top, p_widget_right]
	for i in range(1, NUM_PLAYERS):
		if widgets[i]:
			widgets[i].update_score(players[i].score)
			var count = players[i].hand.size() if current_phase == Phase.PLAYING else players[i].draft_hand.size()
			widgets[i].update_hand(count)
	round_label.text = "ROUND %d / 5" % round_num
	for c in suit_container.get_children(): c.queue_free()
	suit_container.add_theme_constant_override("separation", 15)
	
	for i in range(5):
		var control = Control.new()
		control.custom_minimum_size = Vector2(30, 30)
		var is_active = i < active_suits.size()
		var col = _get_suit_color(active_suits[i]) if is_active else Color(0.1, 0.1, 0.1, 0.6)
		var txt = "" if is_active else "?"
		
		var script = GDScript.new()
		script.source_code = """extends Control
var col=Color.WHITE
var txt=""
func _draw():
	draw_circle(size/2, 13, col)
	draw_arc(size/2, 13, 0, 6.28, 32, Color.WHITE if txt=="" else Color(0.4,0.4,0.4), 2.0)
	if txt != "":
		var f = ThemeDB.fallback_font
		draw_string(f, Vector2(size.x/2 - 4, size.y/2 + 5), txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.6,0.6,0.6))
"""
		if script.reload() == OK:
			control.set_script(script)
			control.set("col", col)
			control.set("txt", txt)
		suit_container.add_child(control)
	
	var instr_label = $"../UI/InstructionLabel"
	if instr_label: instr_label.visible = false 

	if current_phase == Phase.DRAFTING:
		ui_message_label.text = "Drafting: Pick %d" % cards_to_pick
	elif current_phase == Phase.PLAYING:
		if turn_idx == 0: ui_message_label.text = "Your Turn!"
		else: ui_message_label.text = "%s is thinking..." % players[turn_idx].name

func _get_suit_color(s):
	match s:
		"Red": return Color("DC2828")
		"Blue": return Color("285ADC")
		"Green": return Color("28A028")
		"Black": return Color("1E1E1E")
		"White": return Color.WHITE
	return Color.GRAY

func _render_human_draft_hand(animate_in: bool = false):
	for c in card_container.get_children(): c.queue_free()
	confirm_btn.visible = false
	var human = players[0]
	var hand_size = human.draft_hand.size()
	if hand_size == 0: return
	
	if hand_size <= cards_to_pick:
		ui_message_label.text = "Auto-Drafting..."
		for d in human.draft_hand:
			human.hand.append(d)
		human.draft_hand.clear()
		_process_bot_drafts()
		var last_pack = players[NUM_PLAYERS-1].draft_hand
		for i in range(NUM_PLAYERS-1, 0, -1): players[i].draft_hand = players[i-1].draft_hand
		players[0].draft_hand = last_pack
		current_draft_step += 1
		await get_tree().create_timer(0.3).timeout
		if current_draft_step >= 3: _start_play_phase()
		else: _render_human_draft_hand(true)
		return 
	
	var draft_scale = 1.0
	if hand_size > 12: draft_scale = 0.7
	elif hand_size > 9: draft_scale = 0.85
	
	var cols = 6 
	var spacing_x = 180 * draft_scale
	var spacing_y = 220 * draft_scale
	var rows = ceil(float(hand_size) / cols)
	var grid_w = min(hand_size, cols) * spacing_x
	var grid_h = rows * spacing_y
	
	var start_y_offset = 60
	if hand_size > 12: start_y_offset = 120 
	
	var start_x = (1920 - grid_w) / 2 + (spacing_x / 2)
	var start_y = (1080 - grid_h) / 2 + (spacing_y / 2) + start_y_offset
	
	for i in range(hand_size):
		var data = human.draft_hand[i]
		var card = card_scene.instantiate()
		card_container.add_child(card)
		card.set_card_data(data.suit, data.rank)
		var row = floor(i / cols)
		var col = i % cols
		var items_in_this_row = min(hand_size - (row*cols), cols)
		var row_width = items_in_this_row * spacing_x
		var row_start_x = (1920 - row_width) / 2 + (spacing_x / 2)
		var tx = row_start_x + (col * spacing_x)
		var ty = start_y + (row * spacing_y) - 50
		
		card.set_meta("draft_scale", draft_scale)
		if animate_in:
			card.position = Vector2(1920/2, 1080/2) 
			card.scale = Vector2(0.0, 0.0)
			card.modulate.a = 0.0
			var t = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.tween_property(card, "position", Vector2(tx, ty), 0.5 + (i * 0.03))
			t.parallel().tween_property(card, "scale", Vector2(draft_scale, draft_scale), 0.5 + (i * 0.03))
			t.parallel().tween_property(card, "modulate:a", 1.0, 0.5 + (i * 0.03))
		else:
			card.position = Vector2(tx, ty)
			card.scale = Vector2(draft_scale, draft_scale)
			
		card.target_pos = Vector2(tx, ty)
		card.is_drafting = true
		card.is_face_up = true
		card.clicked.connect(_on_card_clicked)
		card.set_meta("data", data)

func _on_card_clicked(card_node):
	if is_exit_popup_open: return

	if current_phase == Phase.DRAFTING:
		if card_node.selected:
			card_node.selected = false
		else:
			var sel_count = 0
			for c in card_container.get_children(): 
				if c.selected: sel_count += 1
			if sel_count < cards_to_pick: 
				card_node.selected = true
				if sound_manager: sound_manager.play_sfx("pickup")
		var count = 0
		for c in card_container.get_children(): if c.selected: count += 1
		
		if count == cards_to_pick:
			confirm_btn.visible = true
			confirm_btn.scale = Vector2.ZERO
			create_tween().tween_property(confirm_btn, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			confirm_btn.visible = false
		
	elif current_phase == Phase.PLAYING:
		if turn_idx != 0: 
			impatient_clicks += 1
			if impatient_clicks >= 10:
				if AchievementManager: AchievementManager.unlock("IMPATIENT")
			return 
		
		impatient_clicks = 0
		var data = card_node.get_meta("data")
		
		if trick_pile.size() > 0:
			var lead = trick_pile[0].data.suit
			if players[0].hand.size() > 1:
				if data.rank == LILY_RANK and lead not in ["Black", "White"] and data.suit != lead:
					var t = create_tween()
					t.tween_property(card_node, "position:x", card_node.position.x + 10, 0.05)
					t.tween_property(card_node, "position:x", card_node.position.x - 10, 0.05)
					t.tween_property(card_node, "position:x", card_node.target_pos.x, 0.05)
					return 
		
		if AchievementManager and data.rank == LILY_RANK:
			var is_leading = true
			for i in range(1, NUM_PLAYERS):
				if players[i].score > players[0].score: is_leading = false
			if is_leading: AchievementManager.unlock("SABOTAGE")

		_play_card(0, card_node, data)

func _on_confirm_pressed():
	if confirm_btn.has_method("animate_hide"):
		confirm_btn.animate_hide(_process_confirm_logic)
	else:
		confirm_btn.visible = false
		_process_confirm_logic()

func _process_confirm_logic():
	var human = players[0]
	var selected_data = []
	var remaining_data = []
	var remaining_nodes = []
	
	for c in card_container.get_children():
		var d = c.get_meta("data")
		if c.selected: 
			selected_data.append(d)
			c.queue_free() 
		else: 
			remaining_data.append(d)
			remaining_nodes.append(c)
			
	human.hand.append_array(selected_data)
	human.draft_hand = remaining_data
	
	for i in range(remaining_nodes.size()):
		var c = remaining_nodes[i]
		c.is_drafting = false 
		var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		t.tween_property(c, "position", p_widget_left.position, 0.35 + (i * 0.03))
		t.parallel().tween_property(c, "scale", Vector2(0.3, 0.3), 0.35 + (i * 0.03))
		t.parallel().tween_property(c, "modulate:a", 0.0, 0.35 + (i * 0.03))
		t.tween_callback(c.queue_free)
	
	if remaining_nodes.size() > 0:
		await get_tree().create_timer(0.45).timeout
		
	_process_bot_drafts()
	var last_pack = players[NUM_PLAYERS-1].draft_hand
	for i in range(NUM_PLAYERS-1, 0, -1):
		players[i].draft_hand = players[i-1].draft_hand
	players[0].draft_hand = last_pack
	current_draft_step += 1
	
	if current_draft_step >= 3:
		_start_play_phase()
	else:
		if sound_manager: sound_manager.play_sfx("turn")
		_render_human_draft_hand(true) 

func _process_bot_drafts():
	var diff = Global.settings["DIFFICULTY"]
	for i in range(1, NUM_PLAYERS):
		var p = players[i]
		if diff == "EASY":
			p.draft_hand.shuffle() 
		else:
			p.draft_hand.sort_custom(func(a, b):
				var score_a = a.rank + (100 if a.suit in ["Black","White"] else 0)
				var score_b = b.rank + (100 if b.suit in ["Black","White"] else 0)
				if a.rank == 8: score_a -= 50
				if b.rank == 8: score_b -= 50
				return score_a < score_b 
			)
		for k in range(cards_to_pick): 
			if p.draft_hand.size() > 0:
				p.hand.append(p.draft_hand.pop_back())

func _start_play_phase():
	current_phase = Phase.PLAYING
	current_trick_dominant_suit = ""
	_update_all_ui()
	for c in card_container.get_children(): c.queue_free()
	var human = players[0]
	human.hand.sort_custom(func(a, b): 
		if a.suit == b.suit: return a.rank < b.rank
		return a.suit < b.suit 
	)
	for d in human.hand:
		var card = card_scene.instantiate()
		card_container.add_child(card)
		card.set_card_data(d.suit, d.rank)
		card.set_meta("data", d)
		card.is_drafting = false
		card.clicked.connect(_on_card_clicked)
		
		card.hovered.connect(func(c): 
			if c.get_meta("played", false): return
			var up_vec = Vector2(0, -1).rotated(c.rotation)
			var bs = c.get_meta("base_scale", 1.0)
			if c._move_tween and c._move_tween.is_valid(): c._move_tween.kill()
			c._move_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			c._move_tween.tween_property(c, "position", c.target_pos + (up_vec * 60 * bs), 0.2)
			c._move_tween.tween_property(c, "scale", Vector2(bs * 1.15, bs * 1.15), 0.2)
			c.z_index = 100
			if sound_manager: sound_manager.play_sfx("hover")
		)
		card.unhovered.connect(func(c): 
			if c.get_meta("played", false): return
			var bs = c.get_meta("base_scale", 1.0)
			if c._move_tween and c._move_tween.is_valid(): c._move_tween.kill()
			c._move_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			c._move_tween.tween_property(c, "position", c.target_pos, 0.2)
			c._move_tween.tween_property(c, "scale", Vector2(bs, bs), 0.2)
			c.z_index = c.get_meta("base_z", 0)
		)
		
	_arrange_hand_arc(true) 
	turn_idx = (round_num - 1) % NUM_PLAYERS
	_check_turn()

func _arrange_hand_arc(animate_in: bool = false):
	var cards = []
	for child in card_container.get_children():
		if child.get_meta("played", false) == false and child.is_drafting == false:
			cards.append(child)
			
	var count = cards.size()
	if count == 0: return
	
	var center_x = 1920.0 / 2.0
	var flatten_amount = max(0, count - 8) * 150.0 
	var radius = 1000.0 + flatten_amount
	var center_y = 1080.0 + radius - 150.0 
	
	var max_width_pixels = 1000.0 
	var theta_max = 2.0 * asin(max_width_pixels / (2.0 * radius))
	var spread = 5.5
	if count > 1:
		spread = min(5.5, rad_to_deg(theta_max) / float(count - 1))
	
	var start_angle = -(float(count - 1) * deg_to_rad(spread)) / 2.0
	
	var base_scale = 1.0
	if count > 8: base_scale = max(0.4, 1.0 - (count - 8) * 0.06)
	
	for i in range(count):
		var card = cards[i]
		var angle = start_angle + (float(i) * deg_to_rad(spread))
		var tx = center_x + (radius * sin(angle))
		var ty = center_y - (radius * cos(angle))
		
		card.target_pos = Vector2(tx, ty)
		card.z_index = i
		card.set_meta("base_z", i)
		card.set_meta("base_scale", base_scale)
		
		if animate_in:
			card.position = Vector2(center_x, center_y + 300) 
			card.modulate.a = 0.0
			card.scale = Vector2(0.0, 0.0)
			var st = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			var delay = randf_range(0.0, 0.4)
			st.tween_interval(delay)
			st.tween_property(card, "position", Vector2(tx, ty), 0.5)
			st.parallel().tween_property(card, "rotation", angle, 0.5)
			st.parallel().tween_property(card, "scale", Vector2(base_scale, base_scale), 0.5)
			st.parallel().tween_property(card, "modulate:a", 1.0, 0.5)
		else:
			if card._move_tween and card._move_tween.is_valid(): card._move_tween.kill()
			card._move_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			card._move_tween.tween_property(card, "position", Vector2(tx, ty), 0.3)
			card._move_tween.tween_property(card, "rotation", angle, 0.3)
			card._move_tween.tween_property(card, "scale", Vector2(base_scale, base_scale), 0.3)

func _play_card(p_idx, card_node, data):
	var p = players[p_idx]
	var data_idx = -1
	for i in range(p.hand.size()):
		if p.hand[i].suit == data.suit and p.hand[i].rank == data.rank:
			data_idx = i
			break
	if data_idx != -1: p.hand.remove_at(data_idx)
	
	card_node.hover_active = false
	card_node.set_meta("played", true)
	card_node.player_tag = p.name 
	
	trick_pile.append({"node": card_node, "data": data, "player": p_idx})
	
	if trick_pile.size() == 1: current_trick_dominant_suit = data.suit
	if data.suit in ["Black", "White"]: current_trick_dominant_suit = "Joker"
	
	if p_idx == 0:
		_arrange_hand_arc()
	
	if sound_manager:
		if data.suit in ["Black", "White"]: sound_manager.play_sfx("impact")
		else: sound_manager.play_sfx("whoosh")

	var card_spacing = 100
	var pile_size = trick_pile.size()
	var total_width = (pile_size - 1) * card_spacing
	var start_x = trick_center.position.x - (total_width / 2.0)
	
	var is_joker = data.suit in ["Black", "White"]
	var is_lily = data.rank == LILY_RANK
	
	for i in range(pile_size):
		var c_info = trick_pile[i]
		var target_x = start_x + (i * card_spacing)
		var target_y = trick_center.position.y
		c_info.node.z_index = 200 + i
		
		if c_info.node == card_node:
			if is_joker:
				card_node.z_index = 300
				var st = create_tween()
				st.tween_property(card_node, "position", Vector2(target_x, target_y - 250), 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				st.parallel().tween_property(card_node, "scale", Vector2(1.6, 1.6), 0.35)
				st.parallel().tween_property(card_node, "rotation", PI * 2, 0.35)
				st.tween_interval(0.1)
				st.tween_property(card_node, "position", Vector2(target_x, target_y), 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
				st.parallel().tween_property(card_node, "scale", Vector2(1.0, 1.0), 0.15)
				st.parallel().tween_callback(func(): card_node.rotation = 0.0).set_delay(0.15)
				st.tween_callback(func():
					for p_other in trick_pile:
						if p_other.node != card_node and p_other.node.has_method("apply_shockwave"):
							p_other.node.apply_shockwave(Vector2(target_x, target_y), 40.0) 
				)
			elif is_lily:
				card_node.z_index = 300
				var st = create_tween()
				st.tween_property(card_node, "position", Vector2(target_x, target_y - 150), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				st.parallel().tween_property(card_node, "scale", Vector2(1.3, 1.3), 0.3)
				st.tween_interval(0.2)
				st.tween_property(card_node, "position", Vector2(target_x, target_y), 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
				st.parallel().tween_property(card_node, "scale", Vector2(1.0, 1.0), 0.15)
				st.tween_callback(func():
					for p_other in trick_pile:
						if p_other.node != card_node:
							if p_other.node.has_method("apply_purple_glow"): p_other.node.apply_purple_glow()
							if p_other.node.has_method("apply_shockwave"): p_other.node.apply_shockwave(Vector2(target_x, target_y), 30.0)
				)
			else:
				c_info.node.move_to(Vector2(target_x, target_y), randf_range(-0.15, 0.15), 0.4)
		else:
			c_info.node.move_to(Vector2(target_x, target_y), randf_range(-0.15, 0.15), 0.4)
	
	turn_idx = (turn_idx + 1) % NUM_PLAYERS
	_update_all_ui()
	
	if trick_pile.size() == NUM_PLAYERS:
		current_phase = Phase.RESOLVING
		await get_tree().create_timer(1.5).timeout
		_resolve_trick()
	else:
		_check_turn()

func _check_turn():
	if current_phase != Phase.PLAYING: return
	_update_all_ui()
	if turn_idx != 0:
		await get_tree().create_timer(1.0).timeout
		_bot_turn()

func _bot_turn():
	var bot = players[turn_idx]
	if bot.hand.size() == 0: return
	var lead_data = trick_pile[0].data if trick_pile.size() > 0 else null
	var valid = []
	for c in bot.hand:
		if lead_data and c.rank == LILY_RANK and lead_data.suit not in ["Black", "White"] and c.suit != lead_data.suit:
			if bot.hand.size() > 1: continue 
		valid.append(c)
	if valid.is_empty(): valid = bot.hand.duplicate() 
	
	var diff = Global.settings["DIFFICULTY"]
	var pick = null
	if diff == "EASY":
		pick = valid.pick_random()
	else:
		var lilies_in_pile = 0
		var power_in_pile = false
		var highest_in_suit = 0
		var lead_suit = lead_data.suit if lead_data else ""
		for p in trick_pile:
			if p.data.rank == LILY_RANK: lilies_in_pile += 1
			if p.data.suit in ["Black", "White"]: power_in_pile = true
			if lead_suit != "" and p.data.suit == lead_suit:
				if p.data.rank > highest_in_suit: highest_in_suit = p.data.rank
		var safe_moves = []
		var winning_moves = []
		for c in valid:
			var will_win = false
			if trick_pile.is_empty():
				if c.rank < 8: safe_moves.append(c) 
				else: winning_moves.append(c) 
			else:
				if c.suit in ["Black", "White"]: will_win = true 
				elif c.suit == lead_suit and not power_in_pile:
					if c.rank > highest_in_suit: will_win = true
				if will_win: winning_moves.append(c)
				else: safe_moves.append(c)
		if lilies_in_pile > 0:
			if safe_moves.size() > 0:
				safe_moves.sort_custom(func(a,b): return a.rank > b.rank)
				pick = safe_moves[0]
			else:
				winning_moves.sort_custom(func(a,b): return a.rank < b.rank)
				pick = winning_moves[0]
		else:
			if winning_moves.size() > 0 and (diff == "HARD" or diff == "IMPOSSIBLE"):
				winning_moves.sort_custom(func(a,b): return a.rank < b.rank)
				pick = winning_moves[0]
			else:
				var lilies = []
				for c in valid: if c.rank == LILY_RANK: lilies.append(c)
				if lilies.size() > 0: pick = lilies[0] 
				else:
					valid.sort_custom(func(a,b): return a.rank < b.rank)
					pick = valid[0]
	if pick == null: pick = valid.pick_random()
	var card = card_scene.instantiate()
	card_container.add_child(card)
	card.set_card_data(pick.suit, pick.rank)
	card.is_face_up = true 
	var start_pos = Vector2(0,0)
	if turn_idx == 1: start_pos = p_widget_left.position
	elif turn_idx == 2: start_pos = p_widget_top.position
	elif turn_idx == 3: start_pos = p_widget_right.position
	card.position = start_pos
	_play_card(turn_idx, card, pick)

func _resolve_trick():
	var lead = trick_pile[0].data.suit
	var best_rank = -1
	var winner = -1
	var power_played = false
	
	var rank_1_played = false
	var power_count = 0
	
	for p in trick_pile: 
		if p.data.suit in ["Black", "White"]: 
			power_played = true
			power_count += 1
		if p.data.rank == 1: rank_1_played = true
	
	for p in trick_pile:
		var d = p.data
		var is_candidate = false
		if power_played:
			if d.suit in ["Black", "White"]:
				if d.rank > best_rank: is_candidate = true
		else:
			if d.suit == lead:
				if d.rank > best_rank: is_candidate = true
		if is_candidate:
			best_rank = d.rank
			winner = p.player
			
	players[winner].tricks_won += 1
	var lilies_count = 0
	var lily_blaster = "" 
	
	var human_played_lily = false
	for p in trick_pile: 
		if p.data.rank == LILY_RANK: 
			lilies_count += 1
			if p.player == 0: human_played_lily = true
			if lily_blaster == "": lily_blaster = players[p.player].name
			
	var points_delta = 3 - (lilies_count * 10)
	players[winner].score += points_delta
	ui_message_label.text = "%s Won the trick!" % players[winner].name
	
	# --- Trigger pour les achievements
	if AchievementManager and winner == 0:
		if best_rank == 1: AchievementManager.unlock("SNIPER")
		if best_rank == 12 and rank_1_played: AchievementManager.unlock("OVERKILL")
		if power_count >= 2 and trick_pile[winner].data.suit in ["Black", "White"]:
			AchievementManager.unlock("POWER_TRIP")
		if lilies_count >= 3: AchievementManager.unlock("STOMACH")
	
	if AchievementManager and winner != 0 and human_played_lily and lilies_count >= 2:
		AchievementManager.unlock("TOXIC")

	var popup = TrickPopup.new()
	$"../UI".add_child(popup)
	popup.play_anim(players[winner].name, points_delta, lily_blaster)
	await popup.popup_finished
	
	current_trick_dominant_suit = ""
	
	if sound_manager:
		if lilies_count > 0: sound_manager.play_sfx("lilytrick")
		elif winner == 0: sound_manager.play_sfx("wintrick")
		else: sound_manager.play_sfx("loosetrick")

	_update_all_ui()
	var dest = Vector2(960, 1200) 
	if winner == 1: dest = p_widget_left.position
	elif winner == 2: dest = p_widget_top.position
	elif winner == 3: dest = p_widget_right.position
	
	for p in trick_pile: 
		var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(p.node, "position", trick_center.position, 0.3)
		t.parallel().tween_property(p.node, "scale", Vector2(0.8, 0.8), 0.3)
		t.chain().tween_property(p.node, "position", dest, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		t.parallel().tween_property(p.node, "scale", Vector2(0.1, 0.1), 0.4)
		t.parallel().tween_property(p.node, "modulate:a", 0.0, 0.4)
		t.parallel().tween_property(p.node, "rotation", PI * 2, 0.4)
	
	await get_tree().create_timer(0.7).timeout
	for p in trick_pile: p.node.queue_free()
	trick_pile.clear()
	
	if players[0].hand.is_empty():
		round_num += 1
		if round_num > 5:
			_check_end_game_achievements()
			if Global.has_method("save_highscore"):
				Global.save_highscore(players[0].score)
			current_phase = Phase.RESOLVING 
			var podium_script = load("res://Scripts/PodiumCinematic.gd")
			if podium_script:
				var podium = podium_script.new()
				$"../UI".add_child(podium)
				podium.start_cinematic(players)
			else:
				if Global.has_method("goto_scene"): Global.goto_scene("res://Scenes/MainMenu.tscn")
		else:
			start_round_setup()
	else:
		current_phase = Phase.PLAYING
		turn_idx = winner
		_check_turn()

func _check_end_game_achievements():
	if not AchievementManager: return
	var player_score = players[0].score
	var player_tricks = players[0].tricks_won
	var diff = Global.settings.get("DIFFICULTY", "NORMAL")
	var sorted_players = players.duplicate()
	sorted_players.sort_custom(func(a,b): return a.score > b.score)
	var player_won = (sorted_players[0] == players[0])
	var runner_up_score = sorted_players[1].score if sorted_players.size() > 1 else 0
	if player_won:
		AchievementManager.stats["wins"] += 1
		AchievementManager.unlock("FIRST_BLOOD")
		if AchievementManager.stats["wins"] >= 5: AchievementManager.unlock("APPRENTICE")
		if AchievementManager.stats["wins"] >= 15: AchievementManager.unlock("ADEPT")
		if AchievementManager.stats["wins"] >= 25: AchievementManager.unlock("LEGEND")
		match diff:
			"EASY": AchievementManager.unlock("DIFF_EASY")
			"NORMAL": AchievementManager.unlock("DIFF_MED")
			"HARD": AchievementManager.unlock("DIFF_HARD")
			"IMPOSSIBLE": AchievementManager.unlock("DIFF_IMP")
		if player_score <= 54: AchievementManager.unlock("CLOSE")
		if player_score - runner_up_score == 1: AchievementManager.unlock("PHOTO")
		if diff == "IMPOSSIBLE" and (player_score - runner_up_score >= 30): AchievementManager.unlock("APEX")
	else: AchievementManager.unlock("HUMBLE")
	if player_score >= 100: AchievementManager.unlock("CENTURION")
	if player_score < 0: AchievementManager.unlock("ABYSS")
	if player_score == 50 and player_tricks == 0: AchievementManager.unlock("NEUTRAL")
	if player_tricks >= 5: AchievementManager.unlock("TRICKSTER")
	if player_tricks >= 10: AchievementManager.unlock("SHARK")
	if player_tricks >= 15: AchievementManager.unlock("DOMINATION")
	AchievementManager.save_data()
