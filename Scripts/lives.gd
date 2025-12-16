extends Node

@onready var character_lives = $CharacterLives
@onready var enemy_lives = $EnemyLives

func update_player_health(player_health: int) -> void:
	for i in range(3):
		var heart = character_lives.get_node("CharLife" + str(i + 1)) as Sprite2D
		heart.visible = i < player_health

func update_enemy_health(enemy_health: int) -> void:
	for i in range(3):
		var heart = enemy_lives.get_node("EnemLife" + str(i + 1)) as Sprite2D
		heart.visible = i < enemy_health
