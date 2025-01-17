extends Control



func _on_ai_pressed():
	Game.wPlayer = "Human"
	Game.bPlayer = "firstbot"
	Game.startingPos = "default"
	Game.setup()
	get_tree().change_scene_to_file("res://scenes/board.tscn")


func _on_ai_vs_ai_pressed():
	Game.wPlayer = "firstbot"
	Game.bPlayer = "firstbot"
	Game.startingPos = "rnbqkb1r/1p1ppppp/p4n2/2p5/2P5/1Q1P1N2/PP2PPPP/RNB1KB1R w KQkq - 0 5"
	Game.setup()
	get_tree().change_scene_to_file("res://scenes/board.tscn")
