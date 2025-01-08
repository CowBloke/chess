extends Control



func _on_ai_pressed():
	Game.wPlayer = "firstbot"
	Game.bPlayer = "Human"
	Game.startingPos = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
	get_tree().change_scene_to_file("res://scenes/board.tscn")
