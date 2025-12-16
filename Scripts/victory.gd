extends Control

func _ready():
	pass

func _on_return_to_menu2() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
