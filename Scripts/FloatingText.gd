extends Node2D
class_name FloatingText

var velocity: Vector2 = Vector2(0, -50)
var duration: float = 1.2
var timer: float = 0.0
var label: Label

func setup(pos: Vector2, txt: String, col: Color):
	position = pos
	
	# Je crée un label sans passer par le système graphique de Godot
	label = Label.new()
	label.text = txt
	label.add_theme_color_override("font_color", col)
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.position = Vector2(-50, -25)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(100, 50)
	
	add_child(label)
	velocity.x = randf_range(-10, 10)

func _process(delta):
	timer += delta
	position += velocity * delta
	modulate.a = 1.0 - (timer / duration)
	if timer >= duration:
		queue_free()
