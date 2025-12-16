extends Control

@onready var question_animation: AnimationPlayer = $VBoxContainer/Question_Animation
@onready var _panel: Panel = $Panel
@onready var _question: RichTextLabel = $VBoxContainer/Question
@onready var _button: Button = $"../Answers/Buttons/Button"
@onready var _button_2: Button = $"../Answers/Buttons/Button2"
@onready var _button_3: Button = $"../Answers/Buttons/Button3"
@onready var _button_4: Button = $"../Answers/Buttons/Button4"

# Whether the UI is locked (prevents the UI from being shown)
var ui_locked: bool = false

# Signal to notify when the player answers
signal answered(is_correct: bool)

# Function to display the question and answers
func display_question(question: String, choices: Array, correct_index: int):
	# If the UI is locked, don't display the question
	if ui_locked:
		return
	
	_panel.visible = true
	_question.bbcodetext = question
	
	# Set up the answers
	_button.text = choices[0]
	_button_2.text = choices[1]
	_button_3.text = choices[2]
	_button_4.text = choices[3]
	
	# Disconnect previous signals and reconnect to the new logic
	disconnect_buttons()
	_button.connect("pressed", Callable(self, "_on_answer_selected").bind(0 == correct_index))
	_button_2.connect("pressed", Callable(self, "_on_answer_selected").bind(1 == correct_index))
	_button_3.connect("pressed", Callable(self, "_on_answer_selected").bind(2 == correct_index))
	_button_4.connect("pressed", Callable(self, "_on_answer_selected").bind(3 == correct_index))

# Function to handle the selected answer
func _on_answer_selected(is_correct: bool):
	print("Answer Correct?: ", is_correct)
	emit_signal("answered", is_correct)
	_panel.visible = false

# Helper to disconnect previous button signals
func disconnect_buttons():
	_button.disconnect("pressed", Callable(self, "_on_answer_selected"))
	_button_2.disconnect("pressed", Callable(self, "_on_answer_selected"))
	_button_3.disconnect("pressed", Callable(self, "_on_answer_selected"))
	_button_4.disconnect("pressed", Callable(self, "_on_answer_selected"))

# Function to lock the UI
func lock_ui():
	ui_locked = true
	_panel.visible = false  # Hide the UI immediately

# Function to unlock the UI
func unlock_ui():
	ui_locked = false
