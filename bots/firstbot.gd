extends Node

var logic : Node
var bestMove

const pawnTable = [0,  0,  0,  0,  0,  0,  0,  0,
50, 50, 50, 50, 50, 50, 50, 50,
10, 10, 20, 30, 30, 20, 10, 10,
 5,  5, 10, 25, 25, 10,  5,  5,
 0,  0,  0, 20, 20,  0,  0,  0,
 5, -5,-10,  0,  0,-10, -5,  5,
 5, 10, 10,-20,-20, 10, 10,  5,
 0,  0,  0,  0,  0,  0,  0,  0]
const knightTable = [-20,-10,-10,-10,-10,-10,-10,-20,-10,  0,  0,  0,  0,  0,  0,-10,-10,  0,  5, 10, 10,  5,  0,-10,-10,  5,  5, 10, 10,  5,  5,-10,-10,  0, 10, 10, 10, 10,  0,-10,-10, 10, 10, 10, 10, 10, 10,-10,-10,  5,  0,  0,  0,  0,  5,-10,-20,-10,-10,-10,-10,-10,-10,-20]


# Function called when bot has to make move

func returnMove(logicNode : Node):
	logic = logicNode
	bestMove = Search(3, -INF, INF, true)
	print("Evaluation:", str(bestMove[0]))
	return bestMove[1]

const pawnValue = 100
const knightValue = 300
const bishopValue = 300
const rookValue = 500
const queenValue = 900

func evaluate():
	var whiteMaterial = countMaterial(true)
	print("white mat")
	print(whiteMaterial)
	var blackMaterial = countMaterial(false)
	print("black mat")
	print(blackMaterial)
	return (whiteMaterial - blackMaterial) 

func _ready() -> void:
	while true:
		print(evaluate())

func Search(depth: int, alpha: int, beta: int, max_: bool) -> Array:
	if depth == 0:
		print("reached depth")
		return [evaluate(), null]

	var moves = logic.GenerateLegalMoves(max_)

	if len(moves) == 0:
		return [-INF, null]  # Checkmate or stalemate

	if max_:
		var maxEval = -INF
		for move_ in moves:
			print("1")
			Game.makeMove(move_, false)
			var result = Search(depth - 1, alpha, beta, false)
			Game.unmakeMove(move_)

			if result[0] > maxEval:
				maxEval = result[0]

			alpha = max(alpha, maxEval)
			if alpha >= beta:
				print("breaking at", str(alpha))
				break  # Beta cutoff

		return [maxEval, bestMove]

	else:
		var minEval = INF
		for move_ in moves:
			Game.makeMove(move_, false)
			var result = Search(depth - 1, alpha, beta, true)
			Game.unmakeMove(move_)

			if result[0] < minEval:
				minEval = result[0]
				bestMove = move_

			beta = min(beta, minEval)
			if alpha >= beta:
				break  # Alpha cutoff

		return [minEval, bestMove]


func countMaterial(white : bool):
	var sum = 0
	var b = Game.board
	var pawntable = pawnTable.duplicate()
	var knighttable = knightTable.duplicate()
	if white:
		pawntable.reverse()
		knighttable.reverse()
	for i in len(b):
		if not b[i] == "" and (b[i].to_lower() == b[i]) == white:
			if b[i].to_lower() == "p": 
				sum += pawnValue
				sum += pawntable[i]
			if b[i].to_lower() == "n": 
				sum += knightValue
				sum += knighttable[i]
			if b[i].to_lower() == "b": 
				sum += bishopValue
			if b[i].to_lower() == "r": 
				sum += rookValue
			if b[i].to_lower() == "q": 
				sum += queenValue
	return sum



	
