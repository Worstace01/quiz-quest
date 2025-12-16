extends Node

var questions = []
var current_question_index = 0

# Player and Enemy Health
var player_health = 3
var enemy_health = 3

@onready var buttons: Panel = $Answers/Buttons
@onready var button_choice_1 = buttons.get_node("Button")
@onready var button_choice_2 = buttons.get_node("Button2")
@onready var button_choice_3 = buttons.get_node("Button3")
@onready var button_choice_4 = buttons.get_node("Button4")
@onready var question: RichTextLabel = $Dialog/VBoxContainer/Question
@onready var panel: Panel = $Dialog/Panel
@onready var player: CharacterBody2D = $"../Player"
@onready var enemy_1: CharacterBody2D = $"../Enemy_1"
@onready var player_animated_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var enemy_animated_sprite: AnimatedSprite2D = enemy_1.get_node("AnimatedSprite2D")
@onready var enemy_lives: Panel = $Lives/EnemyLives
@onready var character_lives: Panel = $Lives/CharacterLives

signal answered(is_correct: bool)

func _ready():
	# Load the questions from the JSON file
	load_questions()

	# Shuffle the questions to ensure random order
	questions.shuffle()

	# Connect the buttons
	button_choice_1.connect("pressed", Callable(self, "_on_button_pressed").bind(button_choice_1))
	button_choice_2.connect("pressed", Callable(self, "_on_button_pressed").bind(button_choice_2))
	button_choice_3.connect("pressed", Callable(self, "_on_button_pressed").bind(button_choice_3))
	button_choice_4.connect("pressed", Callable(self, "_on_button_pressed").bind(button_choice_4))

	display_question()

func load_questions():
	var file = FileAccess.open("res://Assets/Quiz/questions.json", FileAccess.READ)  # Using FileAccess instead of File
	if file:
		var json_data = file.get_as_text()
		file.close()
		
		var json_instance = JSON.new()  # Create an instance of the JSON class
		var result = json_instance.parse(json_data)  # Call parse on the instance

		if result == OK:
			questions = json_instance.get_data()["questions"]
		else:
			print("Error parsing JSON!")
	else:
		print("Failed to open the file!")

func display_question():
	if current_question_index < questions.size():
		var current_question = questions[current_question_index]
		
		# Shuffle the choices
		var shuffled_choices = current_question["choices"].duplicate()
		shuffled_choices.shuffle()
		
		question.text = current_question["question"]
		button_choice_1.text = shuffled_choices[0]
		button_choice_2.text = shuffled_choices[1]
		button_choice_3.text = shuffled_choices[2]
		button_choice_4.text = shuffled_choices[3]
	else:
		print("Quiz finished!")  # Debug

func _on_button_pressed(button: Button):
	var selected_answer = button.text
	var correct_answer = questions[current_question_index]["correct_answer"]

	print("Selected Answer: ", selected_answer, " | Correct Answer: ", correct_answer)  # Debug

	var is_correct = selected_answer.strip_edges() == correct_answer.strip_edges()
	emit_signal("answered", is_correct)

	if is_correct:
		hide_ui_for_animation()
		current_question_index += 1
		display_question()

		enemy_health -= 1
		print("Enemy Health: ", enemy_health)  # Debug
		if enemy_health <= 0:
			enemy_lives.visible = false
			hide_ui_for_animation()
			print("Enemy defeated!")
	else:
		hide_ui_for_animation()
		print("Incorrect answer. Try again.")  # Debug

		player_health -= 1
		print("Player Health: ", player_health)  # Debug
		if player_health <= 0:
			character_lives.visible = false
			hide_ui_for_animation()
			print("Player defeated!")

func reset_quiz():
	print("Resetting quiz...")  # Debug
	current_question_index = 0
	display_question()

# Helper function to hide UI elements (buttons, question, and panel) during animation
func hide_ui_for_animation():
	# Immediately hide the UI
	question.visible = false
	buttons.visible = false
	panel.visible = false
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3.5
	timer.connect("timeout", Callable(self, "show_ui_after_animation"))
	add_child(timer)
	timer.start()

func show_ui_after_animation():
	question.visible = true
	buttons.visible = true
	panel.visible = true


# Function that is called after the delay to play the death animation
func _on_death_animation_timeout(sprite: AnimatedSprite2D):
	sprite.play("death")
