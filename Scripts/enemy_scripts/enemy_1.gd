extends CharacterBody2D

@onready var enemy_animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var quiz_manager: Node = $"../QuizManager"
@onready var player: CharacterBody2D = $"../Player"
@onready var enemy_lives: Panel = $"../QuizManager/Lives/EnemyLives"
@onready var attack: AudioStreamPlayer2D = $attack

const SPEED = 500.0
const STOP_DISTANCE = 5.0

var target_position: Vector2
var is_attacking: bool = false
var start_position: Vector2
var is_facing_left: bool = true  # Start facing left by default
var health: int = 3  # Set default health value

func _ready() -> void:
	start_position = position
	quiz_manager.connect("answered", Callable(self, "_on_answer_received"))
	enemy_animated_sprite.play("idle")

	# Ensure the enemy starts facing left
	enemy_animated_sprite.flip_h = true

# Function that is triggered when the player answers
func _on_answer_received(is_correct: bool) -> void:
	if not is_correct and not is_attacking:
		enemy_lives.visible = false
		target_position = player.position
		enemy_animated_sprite.play("run")
		is_attacking = true
	else:
		reset_to_idle()

# Main process function
func _process(delta: float) -> void:
	if is_attacking:
		var direction = (target_position - position).normalized()
		if position.distance_to(target_position) > STOP_DISTANCE:
			position += direction * SPEED * delta
			flip_sprite_based_on_direction(direction)
		else:
			# Once the enemy reaches the player, play the attack animation
			is_attacking = false
			play_attack_animation()

# Flip the sprite horizontally based on the movement direction
func flip_sprite_based_on_direction(direction: Vector2) -> void:
	if direction.x < 0 and not is_facing_left:
		enemy_animated_sprite.flip_h = true  # Flip to the left
		is_facing_left = true
	elif direction.x > 0 and is_facing_left:
		enemy_animated_sprite.flip_h = false  # Flip to the right
		is_facing_left = false

# Play the attack animation and move back after completion
# Enemy
func play_attack_animation() -> void:
	# Fix the position to avoid vertical movement during attack
	var original_position = position
	
	# Play the attack animation
	attack.play()
	enemy_animated_sprite.play("attack")
	position.y = original_position.y  # Ensure the y position stays the same
	
	# Calculate attack animation duration
	var sprite_frames = enemy_animated_sprite.sprite_frames
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
	player.take_damage()  # Trigger player taking damage
	quiz_manager.get_node("Lives").update_player_health(quiz_manager.player_health)
	move_back_to_start()

# Move the enemy back to the starting position after attacking
func move_back_to_start() -> void:
	enemy_animated_sprite.play("run")
	target_position = start_position

	while position.distance_to(target_position) > STOP_DISTANCE:
		var direction = (target_position - position).normalized()
		position += direction * SPEED * get_process_delta_time()
		flip_sprite_based_on_direction(direction)
		await get_tree().process_frame

	reset_to_idle()

# Reset to idle state
func reset_to_idle() -> void:
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	enemy_lives.visible = true
	enemy_animated_sprite.play("idle")
	enemy_animated_sprite.flip_h = true
	is_facing_left = true

# Function to handle taking damage from the player
# Function to handle taking damage from the player
func take_damage() -> void:
	health -= 1  # Reduce health
	if health <= 0:
		# Hide the UI immediately when the enemy is defeated
		quiz_manager.hide_ui_for_animation()  # Call the function to hide UI
		die()
	else:
		# Existing code for handling hit animation
		$AnimatedSprite2D.modulate = Color(1, 0.5, 0.5, 1)
		enemy_animated_sprite.stop()
		enemy_animated_sprite.play("hit", false)

		# Ensure the 'hit' animation exists
		var sprite_frames = enemy_animated_sprite.sprite_frames
		if sprite_frames and sprite_frames.has_animation("hit"):
			# Calculate the duration of the 'hit' animation
			var frame_count = sprite_frames.get_frame_count("hit")
			var frame_speed = sprite_frames.get_animation_speed("hit")
			var hurt_duration = frame_count / frame_speed
			
			# Print for debugging purposes
			print("Hurt animation duration: ", hurt_duration)
			
			# Create a timer that will reset to idle after the 'hit' animation finishes
			var timer = Timer.new()
			timer.one_shot = true
			timer.wait_time = hurt_duration  # Duration of the hit animation
			timer.connect("timeout", Callable(self, "reset_to_idle"))
			add_child(timer)  # Add the timer to the scene
			timer.start()  # Start the timer
		else:
			print("No 'hit' animation found or sprite frames are missing.")

# Death function when health reaches 0
func die() -> void:
	enemy_animated_sprite.play("death")
	
	# Ensure the animation does not loop
	enemy_animated_sprite.play("death", false)

	# Calculate the duration of the death animation
	var sprite_frames = enemy_animated_sprite.sprite_frames
	if sprite_frames:
		var frame_count = sprite_frames.get_frame_count("death")
		var frame_speed = sprite_frames.get_animation_speed("death")
		var death_duration = frame_count / frame_speed
		
		# Create a timer to handle post-death actions
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = death_duration
		timer.connect("timeout", Callable(self, "_on_death_complete"))
		add_child(timer)
		timer.start()

	set_process(false)  # Stop all further processing

func _on_death_complete() -> void:
	# Stop animations and handle visibility
	enemy_animated_sprite.stop()
	enemy_animated_sprite.frame = enemy_animated_sprite.sprite_frames.get_frame_count("death") - 1
	print("Player has died and is now inactive!")
