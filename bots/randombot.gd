extends Node

# Function called when bot has to make move

func returnMove(availMoves : Array[move]) -> move:
	for i in availMoves:
		if i.flag == move.Flags.CASTLING:
			return i
	return availMoves.pick_random()
