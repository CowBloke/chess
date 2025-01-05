extends Node

# Function called when bot has to make move

func returnMove(logic : Node) -> move:
	var availMoves = logic.GenerateLegalMoves(Game.whiteToMove)
	return availMoves.pick_random()
