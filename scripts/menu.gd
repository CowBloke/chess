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
	Game.startingPos = "r1bqkb1r/pp2pppp/2np1n2/2p5/2P1P3/3P4/PP2NPPP/RNBQKB1R w KQkq - 2 5"
	Game.setup()
	get_tree().change_scene_to_file("res://scenes/board.tscn")
