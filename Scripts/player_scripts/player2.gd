extends CharacterBody2D

@onready var player_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var quiz_manager: Node = $"../QuizManager"
@onready var enemy_1: CharacterBody2D = $"../Enemy_1"
@onready var character_lives: Panel = $"../QuizManager/Lives/CharacterLives"
@onready var panel: Panel = $"../QuizManager/Dialog/Panel"
@onready var buttons: Panel = $"../QuizManager/Answers/Buttons"
@onready var question: RichTextLabel = $"../QuizManager/Dialog/VBoxContainer/Question"
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSFX
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX

const SPEED = 500.0
const STOP_DISTANCE = 15.0

var initial_position: Vector2
var target_position: Vector2
var is_attacking: bool = false
var start_position: Vector2
var is_facing_left: bool = false  # Start facing right by default
var health: int = 3  # Set default health value
var transitioning_to_next_stage: bool = false  # New variable for stage transition
var ui_locked: bool = false  # Track UI state

func _ready() -> void:
	initial_position = Vector2(-400, position.y)  # Set the initial position off-screen
	start_position = position
	
	# Set the player's position to the initial position
	position = initial_position
	
	# Set the initial facing direction of the player (right)
	player_animated_sprite.flip_h = false
	
	# Connect the "answered" signal from the quiz manager
	quiz_manager.connect("answered", Callable(self, "_on_answer_received"))
	player_animated_sprite.play("idle")
	
	# Start moving to the starting position
	move_to_start_position()

# Function to move the player to the starting position
func move_to_start_position() -> void:
	var tween = get_tree().create_tween()
	
	hide_ui_for_animation()
	character_lives.visible = false
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.5
	timer.connect("timeout", Callable(self, "show_ui_after_animation"))
	add_child(timer)
	timer.start()
	
	player_animated_sprite.play("run")
	tween.tween_property(self, "position", start_position, 0.5)

# Function to handle when the quiz manager sends an answer
func _on_answer_received(is_correct: bool) -> void:
	if ui_locked:
		return  # Prevent handling new answers if the UI is locked

	if is_correct and not is_attacking:
		# Hide UI and move towards the enemy
		hide_ui_for_animation()
		character_lives.visible = false
		target_position = enemy_1.position
		player_animated_sprite.play("run")
		is_attacking = true
	else:
		reset_to_idle()

# Main processing function that updates movement and attack behavior
func _process(delta: float) -> void:
	if transitioning_to_next_stage:
		# Move the player to the right
		position.x += SPEED * delta

		# Check if the player has moved completely off-screen
		if position.x > get_viewport_rect().size.x:
			load_next_stage()
		return

	if is_attacking:
		var direction = (target_position - position).normalized()
		if position.distance_to(target_position) > STOP_DISTANCE + 5:
			position += direction * SPEED * delta
			flip_sprite_based_on_direction(direction)
		else:
			# Once the player reaches the target, play the attack animation
			is_attacking = false
			play_attack_animation()

# Function to flip the sprite based on the direction of movement
func flip_sprite_based_on_direction(direction: Vector2) -> void:
	if direction.x < 0 and not is_facing_left:
		player_animated_sprite.flip_h = true  # Flip to the left
		is_facing_left = true
	elif direction.x > 0 and is_facing_left:
		player_animated_sprite.flip_h = false  # Flip to the right
		is_facing_left = false

# Function to play the attack animation
func play_attack_animation() -> void:
	# Fix the position to avoid vertical movement during attack
	var original_position = position
	
	# Play the attack animation
	attack_sfx.play()
	player_animated_sprite.play("attack")
	position.y = original_position.y  # Ensure the y position stays the same
	
	# Calculate attack animation duration
	var sprite_frames = player_animated_sprite.sprite_frames
	if sprite_frames:
		var frame_count = sprite_frames.get_frame_count("attack")
		var frame_speed = sprite_frames.get_animation_speed("attack")
		var attack_duration = frame_count / frame_speed

		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = attack_duration
		timer.connect("timeout", Callable(self, "_on_attack_finished"))
		add_child(timer)
		timer.start()

# Called when the attack animation finishes
func _on_attack_finished() -> void:
	enemy_1.take_damage()  # Trigger enemy taking damage
	
	# Get enemy health from the QuizManager
	var current_enemy_health = quiz_manager.enemy_health  
	quiz_manager.get_node("Lives").update_enemy_health(current_enemy_health)  # Update health graphics

	if current_enemy_health <= 0:
		# Lock the UI and transition to the next stage
		lock_ui()
		transition_to_next_stage()
	else:
		move_back_to_start()

# Function to move the player back to its starting position after attacking
func move_back_to_start() -> void:
	player_animated_sprite.play("run")
	target_position = start_position

	while position.distance_to(target_position) > STOP_DISTANCE - 5:
		var direction = (target_position - position).normalized()
		position += direction * SPEED * get_process_delta_time()
		flip_sprite_based_on_direction(direction)
		await get_tree().process_frame

	reset_to_idle()

# Reset to idle state
func reset_to_idle() -> void:
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	character_lives.visible = true
	player_animated_sprite.play("idle")
	# Ensure the idle sprite faces right
	player_animated_sprite.flip_h = false
	is_facing_left = false

# Function to handle taking damage from the enemy
func take_damage() -> void:
	health -= 1  # Reduce health
	if health <= 0:
		die()
	else:
		$AnimatedSprite2D.modulate = Color(1, 0.5, 0.5, 1)
		player_animated_sprite.stop()
		player_animated_sprite.play("hit", false)  # Play 'hit' animation once

		var sprite_frames = player_animated_sprite.sprite_frames
		if sprite_frames and sprite_frames.has_animation("hit"):
			var frame_count = sprite_frames.get_frame_count("hit")
			var frame_speed = sprite_frames.get_animation_speed("hit")
			var hurt_duration = frame_count / frame_speed
			
			var timer = Timer.new()
			timer.one_shot = true
			timer.wait_time = hurt_duration
			timer.connect("timeout", Callable(self, "reset_to_idle"))
			add_child(timer)
			timer.start()

# Death function when health reaches 0
func die() -> void:
	death_sfx.play()
	player_animated_sprite.play("death", false)  # Play the death animation
	var sprite_frames = player_animated_sprite.sprite_frames
	if sprite_frames:
		var frame_count = sprite_frames.get_frame_count("death")
		var frame_speed = sprite_frames.get_animation_speed("death")
		var death_duration = frame_count / frame_speed
		
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = death_duration
		timer.connect("timeout", Callable(self, "_on_death_complete"))
		add_child(timer)
		timer.start()

	set_process(false)  # Stop all further processing

func _on_death_complete() -> void:
	player_animated_sprite.stop()
	player_animated_sprite.frame = player_animated_sprite.sprite_frames.get_frame_count("death") - 1
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1.2
	timer.connect("timeout", Callable(self, "gameover"))
	add_child(timer)
	timer.start()
	
	print("Player has died and is now inactive!")

func gameover():
	get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
	
# Function to start the transition to the next stage
func transition_to_next_stage() -> void:
	transitioning_to_next_stage = true
	player_animated_sprite.play("run")  # Play the running animation
	is_facing_left = false
	
	# Hide the UI immediately when the transition starts
	hide_ui_for_animation()  # Ensure the UI is hidden
	player_animated_sprite.flip_h = false  # Ensure the player is facing right

# Function to load the next stage
func load_next_stage() -> void:
	# Load the next scene (change to the next stage)
	get_tree().change_scene_to_file("res://Scenes/game3.tscn")
	
# Utility functions to manage the UI
func hide_ui_for_animation():
	# Immediately hide the UI
	question.visible = false
	buttons.visible = false
	panel.visible = false
	
func show_ui_after_animation():
	question.visible = true
	buttons.visible = true
	panel.visible = true
	character_lives.visible = true
	reset_to_idle()

func lock_ui():
	ui_locked = true

func unlock_ui():
	ui_locked = false
