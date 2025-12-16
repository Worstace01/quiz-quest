extends Control

@onready var music: AudioStreamPlayer2D = $music
@onready var button: Button = $VBoxContainer/Button
@onready var button_2: Button = $VBoxContainer/Button2
@onready var title: Sprite2D = $VBoxContainer/Title
@onready var color_rect: ColorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.visible = false
	button_2.visible = false
	title.modulate.a = 0  # Start with fully transparent title
	button.modulate.a = 0  # Start with fully transparent buttons
	button_2.modulate.a = 0  # Same for button_2
	color_rect.visible = true
	color_rect.color.a = 1.0  # Start fully opaque (black screen)

	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 5.0  # Delay before showing buttons
	timer.connect("timeout", Callable(self, "show_buttons"))
	add_child(timer)
	timer.start()
	Audioplayer.play_music_level()

	# Add a timer to control the fade-out effect for the color_rect
	var fade_timer = Timer.new()
	fade_timer.one_shot = true
	fade_timer.wait_time = 4.0  # Wait time before starting fade out (can adjust)
	fade_timer.connect("timeout", Callable(self, "start_fade_out"))
	add_child(fade_timer)
	fade_timer.start()

# Function to show the buttons and title with a fade-in effect
func show_buttons() -> void:
	button.visible = true
	button_2.visible = true
	title.visible = true  # Make the title visible for fade-in effect

	# Create separate tweening objects for each button and title
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()

	# Animate button opacity to 1 (fade in) for both buttons simultaneously
	tween1.tween_property(button, "modulate:a", 1.0, 1.0)  # Fade in button 1
	tween2.tween_property(button_2, "modulate:a", 1.0, 1.0)  # Fade in button 2

	# Animate title opacity to 1 (fade in)
	tween3.tween_property(title, "modulate:a", 1.0, 1.0)  # Fade in title

# Function to start the fade-out effect for the whole screen
func start_fade_out() -> void:
	# Create a tween for the color_rect fade-out effect
	var tween = get_tree().create_tween()

	# Animate the color_rect opacity to 0 (fade out)
	tween.tween_property(color_rect, "color:a", 0.0, 1.0)

func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
