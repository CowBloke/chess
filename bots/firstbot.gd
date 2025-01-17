extends Node

var logic : Node
var bestMove : move = move.new()

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
	return bestMove

func startSearch():
	Search(3 , -1000000, 1000000, true)

const pawnValue = 100
const knightValue = 300
const bishopValue = 320
const rookValue = 500
const queenValue = 900

func evaluate():
	var whiteMaterial = countMaterial(true)
	var blackMaterial = countMaterial(false)
	return (whiteMaterial - blackMaterial) * (1 if Game.whiteToMove else -1)


func Search(depth: int, alpha : int, beta : int, isRoot : bool) -> int:
	if depth == 0:
		return evaluate()
	var moves = orderMoves(logic.GenerateMoves(Game.whiteToMove))

	if len(moves) == 0:
		return -1000000  # Checkmate or stalemate

	var maxEval = -1000000
	var legal_yet = false
	for move_ in moves:
		if logic.isLegalMove(move_, Game.whiteToMove):
			legal_yet = true
			if bestMove == null:
				bestMove = move_
			Game.makeMove(move_, false)
			var result = -Search(depth - 1, -beta, -alpha, false)
			Game.unmakeMove()
			if result > maxEval:
				if isRoot:
					bestMove = move_
				maxEval = result
			if maxEval > alpha:
				alpha = maxEval
			if maxEval >= beta:
				return alpha
		else:
			pass
	if legal_yet == false:
		return -100000
	else:
		return alpha


func countMaterial(white : bool):
	var sum = 0
	var b = Game.board.duplicate()
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
		if isFriendlyPiece(b[i], white):
			var piece = b[i] & 0b111
			if piece == 0b001: 
				sum += pawnValue
				sum += pawntable[i]
			if piece == 0b010: 
				sum += knightValue
				sum += knighttable[i]
			if piece == 0b011: 
				sum += bishopValue
				sum += bishoptable[i]
			if piece == 0b100: 
				sum += rookValue
				sum += rooktable[i]
			if piece == 0b101: 
				sum += queenValue
				sum += queentable[i]
			if piece == 0b110: 
				sum += kingtable[i]
	return sum

func moveOrderingScores(moves : Array[move]) -> Array:
	var board = Game.board.duplicate()
	var moveScores = []
	var pieceValueTable = {0b101:queenValue, 0b100:rookValue, 0b011:bishopValue, 0b010:knightValue, 0b001:pawnValue, 0b110:1000}
	for i in moves:
		var pieceScore = 0
		if not board[i.getEnd()] == 0:
			var pieceDifference = pieceValueTable[board[i.getEnd()]& 0b111 ] - pieceValueTable[board[i.getStart()] & 0b111 ]
			if pieceDifference >= 0 :
				pieceScore += pieceDifference
		if i.isPromotion():
			match i.getFlag():
				move.Flags.QUEEN_PROMOTE:
					pieceScore += queenValue
				move.Flags.ROOK_PROMOTE:
					pieceScore += rookValue
				move.Flags.BISHOP_PROMOTE:
					pieceScore += bishopValue
				move.Flags.KNIGHT_PROMOTE:
					pieceScore += knightValue
		moveScores.append(pieceScore)
	return moveScores

func orderMoves(moves : Array[move]) -> Array[move]:
	var movelist = moves.duplicate()
	var moveScores = moveOrderingScores(movelist)
	for i in range(len(moves)-1):
		var j = i+1
		while j > 0:
			j -= 1
			var swapidx = j-1
			if moveScores[swapidx] < moveScores[j]:
				var temp = moves[j]
				moves[j] = moves[swapidx]
				moves[swapidx] = temp
				temp = moveScores[j]
				moveScores[j] = moveScores[swapidx]
				moveScores[swapidx] = temp
	return movelist
	

func isFriendlyPiece(piece : int, white : bool) -> bool:
	if piece == 0:
		return false
	if (piece >>3) == (1 if white else 0):
		return true
	else:
		return false
	
