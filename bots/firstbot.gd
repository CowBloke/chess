extends Node

var logic : Node
var bestMove : move

const pawnTable = [0,0,0,0,0,0,0,0,50,50,50,50,50,50,50,50,10,10,20,30,30,20,10,10,5,5,10,25, 25, 10,  5,  5,0,  0,  0, 20, 20,  0,  0,  0,5, -5,-10,  0,  0,-10, -5,  5,5, 10, 10,-20,-20, 10, 10,  5,0,  0,  0,  0,  0,  0,  0,  0]
const knightTable = [-20,-10,-10,-10,-10,-10,-10,-20,-10,0,0,0,0,0,  0,-10,-10,  0,  5, 10, 10,  5,  0,-10,-10,  5,  5, 10, 10,  5,  5,-10,-10,  0, 10, 10, 10, 10,  0,-10,-10, 10, 10, 10, 10, 10, 10,-10,-10,  5,  0,  0,  0,  0,  5,-10,-20,-10,-10,-10,-10,-10,-10,-20]
const bishopTable = [-20,-10,-10,-10,-10,-10,-10,-20,-10,  0,  0,  0,  0,  0,  0,-10,-10,  0,  5, 10, 10,  5,  0,-10,-10,  5,  5, 10, 10,  5,  5,-10,-10,  0, 10, 10, 10, 10,  0,-10,-10, 10, 10, 10, 10, 10, 10,-10,-10,  5,  0,  0,  0,  0,  5,-10,-20,-10,-10,-10,-10,-10,-10,-20,]
const rookTable = [0,  0,  0,  0,  0,  0,  0,  0,5, 10, 10, 10, 10, 10, 10,  5,-5,  0,  0,  0,  0,  0,  0, -5,-5,  0,  0,  0,  0,  0,  0, -5,-5,  0,  0,  0,  0,  0,  0, -5,-5,  0,  0,  0,  0,  0,  0, -5,-5,  0,  0,  0,  0,  0,  0, -5,0,  0,  0,  5,  5,  0,  0,  0]
const queenTable = [-20,-10,-10, -5, -5,-10,-10,-20,-10,  0,  0,  0,  0,  0,  0,-10,-10,  0,  5,  5,  5,  5,  0,-10,-5,  0,  5,  5,  5,  5,  0, -5,0,  0,  5,  5,  5,  5,  0, -5,-10,  5,  5,  5,  5,  5,  0,-10,-10,  0,  5,  0,  0,  0,  0,-10,-20,-10,-10, -5, -5,-10,-10,-20]
const kingTable = [-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-20,-30,-30,-40,-40,-30,-30,-20,-10,-20,-20,-20,-20,-20,-20,-10,20, 20,  0,  0,  0,  0, 20, 20,20, 30, 10,  0,  0, 10, 30, 20]

# Function called when bot has to make move

func returnMove(logicNode : Node):
	logic = logicNode
	var thread = Thread.new()
	thread.start(startSearch)
	thread.wait_to_finish()
	Game.makeMove(bestMove, false)
	print(evaluate())
	Game.unmakeMove(bestMove)
	return bestMove

func startSearch():
	Search(3, -INF, INF, true)

const pawnValue = 100
const knightValue = 300
const bishopValue = 320
const rookValue = 500
const queenValue = 900

func evaluate():
	var whiteMaterial = countMaterial(true)
	var blackMaterial = countMaterial(false)
	return (whiteMaterial - blackMaterial) * (-1 if Game.whiteToMove else 1)


func Search(depth: int, alpha : int, beta : int, isRoot : bool) -> int:
	if depth == 0:
		return evaluate()
	var moves = logic.GenerateLegalMoves(Game.whiteToMove)

	if len(moves) == 0:
		return -INF  # Checkmate or stalemate

	var maxEval = -INF
	for move_ in moves:
		Game.makeMove(move_, false)
		var result = -Search(depth - 1, -alpha, -beta, false)
		Game.unmakeMove(move_)
		if result > maxEval:
			if isRoot:
				bestMove = move_
			maxEval = result
		if maxEval > alpha:
			alpha = maxEval
		if maxEval >= beta:
			return alpha
		
	return alpha


func countMaterial(white : bool):
	var sum = 0
	var b = Game.board
	var pawntable = pawnTable.duplicate()
	var knighttable = knightTable.duplicate()
	var bishoptable = bishopTable.duplicate()
	var rooktable = rookTable.duplicate()
	var queentable = queenTable.duplicate()
	var kingtable = kingTable.duplicate()
	if not white:
		pawntable.reverse()
		knighttable.reverse()
		bishoptable.reverse()
		rooktable.reverse()
		queentable.reverse()
		kingtable.reverse()
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
				sum += bishoptable[i]
			if b[i].to_lower() == "r": 
				sum += rookValue
				sum += rooktable[i]
			if b[i].to_lower() == "q": 
				sum += queenValue
				sum += queentable[i]
			if b[i].to_lower() == "k": 
				sum += kingtable[i]
	return sum



	
