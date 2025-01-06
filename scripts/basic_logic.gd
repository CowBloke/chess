extends Node

const Knight = [[-1, -2],[1, -2],[-1, 2],[1, 2],[2, -1],[2, 1],[-2, -1],[-2, 1],]
const King = [[-1, -1],[0, -1],[1, -1],[-1, 0],[1, 0],[-1, 1],[0, 1],[1, 1],]
const Bishop = [[1, -1], [-1, -1], [-1, 1], [1, 1]]
const Rook = [[1, 0], [-1, 0], [0, 1], [0, -1]]
const Queen = [[1, -1], [-1, -1], [-1, 1], [1, 1],[1, 0], [-1, 0], [0, 1], [0, -1]]

const bishopOffsets = [-7, 9, 7, -9]
const rookOffsets = [-8, 1, 8, -1]
const queenOffsets = [-8, 1, 8, -1, -7, 9, 7, -9]

var precomputedMoveData = []

var board : Array
var moves : Array[move]

var pawns : Array
var knights : Array
var bishops : Array
var rooks : Array
var queens : Array
var king : int

#func updateBitboards():
	#var all_pieces = white_pieces|black_pieces
	#var empty_squares = ~all_pieces
	#var white_pieces = white_pawns | white_rooks | white_knights | white_bishops | white_queen | white_king
	#var black_pieces = black_pawns | black_rooks | black_knights | black_bishops | black_queen | black_king
#
#func generateBishopMoves(white : bool):
	#var friendlyBishops = white_bishops if white else black_bishops
	#var friendlyPieces = white_pieces if white else black_pieces
	#var enemyPieces = black_pieces if white else white_pieces
	
	#for i in bishopOffsets:
		#var tempBishops = friendlyBishops >> i
		#if tempBishops == 0:
			#pass
		#else:
			#pass
	#

func _ready() -> void:
	calculatePrecomputedMoveData()

func calculatePrecomputedMoveData():
	for rank in range(8):
		for file in range(8):
			var numNorth = rank
			var numSouth = 7 - rank
			var numWest = file
			var numEast = 7 - file
			precomputedMoveData.append([numNorth, numEast, numSouth, numWest, min(numNorth, numEast), min(numEast, numSouth), min(numSouth, numWest), min(numWest, numNorth)])
			

func GenerateAttackSquares(white : bool):
	var captureSquares : Array[int] = []
	var move_list = GenerateLegalMoves(white)
	for i in move_list:
		if not i.getEnd() in captureSquares:
			captureSquares.append(i.getEnd())
	return captureSquares
		

#func CountPossibleNodes(depth : int):
		#return 1
	#var moves = GenerateLegalMoves(Game.whiteToMove)
	#var counter = 0
	#for i in moves:
		#Game.makeMove(i, false)
		#counter += CountPossibleNodes(depth - 1)
		#Game.unmakeMove(i)
	#return counter


func GenerateMoves(white : bool):
	moves = []
	board = Game.board.duplicate()
	if not white:
		board.reverse()

	createPieceLists(white)
	#var ms = Time.get_ticks_msec()
	GeneratePawnMoves(white)
	#print("Pawn : ", Time.get_ticks_msec()-ms)
	#ms = Time.get_ticks_msec()
	GenerateKnightMoves(white)
	#print("Knight : ", Time.get_ticks_msec()-ms)
	#ms = Time.get_ticks_msec()
	GenerateBishopMoves(white)
	#print("Bishop : ", Time.get_ticks_msec()-ms)
	#ms = Time.get_ticks_msec()
	GenerateRookMoves(white)
	#print("Rook : ", Time.get_ticks_msec()-ms)
	#ms = Time.get_ticks_msec()
	GenerateQueenMoves(white)
	#print("Queen : ", Time.get_ticks_msec()-ms)
	#ms = Time.get_ticks_msec()
	GenerateKingMoves(white)
	#print("King : ", Time.get_ticks_msec()-ms)
	#ms = Time.get_ticks_msec()
	return moves

func isCheck(white : bool):
	var attack_squares = GenerateAttackSquares(white)
	createPieceLists(not white)
	if Game.board.find("k" if white else "K") in attack_squares:
		return true
	else:
		return false
	
func isCheckmate(white : bool):
	if GenerateLegalMoves(white) == []:
		print("Checkmate")
		return true
	else:
		return false

func GenerateLegalMoves(white):
	var base_moves = GenerateMoves(white)
	var legal_moves = base_moves.duplicate()

	for i in range(len(base_moves)):
		Game.makeMove(base_moves[i], false)
		var current_moves = GenerateMoves(not white)
		createPieceLists(white)
		for j in current_moves:
			if j.getEnd() == Game.board.find("K" if white else "k"):
				legal_moves.remove_at(legal_moves.find(base_moves[i]))
				break
		Game.unmakeMove(base_moves[i])
	return legal_moves

func rank(nb : int):
	return floor((nb)/8)

func file(nb : int):
	return nb%8

func GeneratePawnMoves(white : bool):
	for i in pawns:
		if board[i-8] == "":
			if rank(i-8) == 0: # If promotion
				moves.append(returnMove(i, i-8, white, move.Flags.QUEEN_PROMOTE))
				moves.append(returnMove(i, i-8, white, move.Flags.KNIGHT_PROMOTE))
				moves.append(returnMove(i, i-8, white, move.Flags.BISHOP_PROMOTE))
				moves.append(returnMove(i, i-8, white, move.Flags.ROOK_PROMOTE))
			else:
				moves.append(returnMove(i, i-8, white))
			if board[i-16] == "" and rank(i) == 6:
				moves.append(returnMove(i, i-16, white))
		
		if isEnemyPiece(board[i-9], white) and not file(i) == 0:
			if rank(i-9) == 0: # If promotion
				moves.append(returnMove(i, i-9, white, move.Flags.QUEEN_PROMOTE))
				moves.append(returnMove(i, i-9, white, move.Flags.KNIGHT_PROMOTE))
				moves.append(returnMove(i, i-9, white, move.Flags.BISHOP_PROMOTE))
				moves.append(returnMove(i, i-9, white, move.Flags.ROOK_PROMOTE))
			else:
				moves.append(returnMove(i, i-9, white))
			
		if isEnemyPiece(board[i-7], white) and not file(i) == 7:
			if rank(i-7) == 0: # If promotion
				moves.append(returnMove(i, i-7, white, move.Flags.QUEEN_PROMOTE))
				moves.append(returnMove(i, i-7, white, move.Flags.KNIGHT_PROMOTE))
				moves.append(returnMove(i, i-7, white, move.Flags.BISHOP_PROMOTE))
				moves.append(returnMove(i, i-7, white, move.Flags.ROOK_PROMOTE))
			else:
				moves.append(returnMove(i, i-7, white))
		if len(Game.moves) > 1:
			if rank(i) == 3: # en passant
				if board[i+1] == ("p" if white else "P"):
					if (Game.moves[len(Game.moves)-1].getEnd() if white else 63 - Game.moves[len(Game.moves)-1].getEnd()) == i+1 and not i%8 == 7:
						moves.append(returnMove(i, i-7, white, move.Flags.ENPASSANT))
					if (Game.moves[len(Game.moves)-1].getEnd() if white else 63 - Game.moves[len(Game.moves)-1].getEnd()) == i-1 and not i%8 == 0:
						moves.append(returnMove(i, i-9, white, move.Flags.ENPASSANT))

func GenerateKnightMoves(white : bool):
	for i in knights:
		for j in Knight:
				if isMoveValidSquare(i, j[0], j[1]):
					if isEnemyPiece(board[getMoveDisplacement(i, j[0], j[1])], white) or (board[getMoveDisplacement(i, j[0], j[1])] == ""):
						moves.append(returnMove(i, getMoveDisplacement(i, j[0], j[1]), white))

func GenerateBishopMoves(white : bool):
	for i in bishops:
		for j in range(len(bishopOffsets)):
			var mult = 1
			for k in range(precomputedMoveData[i][j+4]):
				if isFriendlyPiece(board[i+(bishopOffsets[j] * mult)], white):
					break
				moves.append(returnMove(i, i+(bishopOffsets[j] * mult), white))
				if isEnemyPiece(board[i+(bishopOffsets[j] * mult)], white):
					break
				mult += 1

func GenerateRookMoves(white : bool):
	for i in rooks:
		for j in range(len(rookOffsets)):
			var mult = 1
			for k in range(precomputedMoveData[i][j]):
				if isFriendlyPiece(board[i+(rookOffsets[j] * mult)], white):
					break
				moves.append(returnMove(i, i+(rookOffsets[j] * mult), white))
				if isEnemyPiece(board[i+(rookOffsets[j] * mult)], white):
					break
				mult += 1

func GenerateQueenMoves(white : bool):
	for i in queens:
		for j in range(len(queenOffsets)):
			var mult = 1
			for k in range(precomputedMoveData[i][j]):
				if isFriendlyPiece(board[i+(queenOffsets[j] * mult)], white):
					break
				moves.append(returnMove(i, i+(queenOffsets[j] * mult), white))
				if isEnemyPiece(board[i+(queenOffsets[j] * mult)], white):
					break
				mult += 1

func GenerateKingMoves(white : bool):
	for j in King:
		if isMoveValidSquare(king, j[0], j[1]):
			if isEnemyPiece(board[getMoveDisplacement(king, j[0], j[1])], white) or (board[getMoveDisplacement(king, j[0], j[1])] == ""):
				moves.append(returnMove(king, getMoveDisplacement(king, j[0], j[1]), white))
		if white:
			if Game.whiteCastleKingSide:
				if board[king+1] == "" and board[king+2] == "":
					moves.append(returnMove(king, king+2, white, move.Flags.CASTLING))
			if Game.whiteCastleQueenSide:
				if board[king-1] == "" and board[king-2] == "" and board[king-3] == "":
					moves.append(returnMove(king, king-2, white, move.Flags.CASTLING))
		else:
			if Game.blackCastleKingSide:
				if board[king-1] == "" and board[king-2] == "":
					moves.append(returnMove(king, king-2, white, move.Flags.CASTLING))
			if Game.blackCastleQueenSide:
				if board[king+1] == "" and board[king+2] == "" and board[king+3] == "":
					moves.append(returnMove(king, king+2, white, move.Flags.CASTLING))

# Helper Functions

func createPieceLists(white : bool):
	pawns = []
	knights = []
	bishops = []
	rooks = []
	queens = []
	king = 0
	for i in range(len(board)):
		if not board[i] == "":
			if isFriendlyPiece(board[i], white): # Checking if it's the same color
				if board[i].to_lower() == "p": 
					pawns.append(i)
				if board[i].to_lower() == "n": 
					knights.append(i)
				if board[i].to_lower() == "b": 
					bishops.append(i)
				if board[i].to_lower() == "r": 
					rooks.append(i)
				if board[i].to_lower() == "q": 
					queens.append(i)
				if board[i].to_lower() == "k": 
					king = i

func returnMove(start : int, end : int, white : bool, flag : move.Flags = move.Flags.NONE) -> move:
	var newmove = move.new()
	if not white:
		start = 63-start
		end = 63-end
	newmove.movedata = (((start<<6)| end )<< 4)|flag
	return newmove

func isMoveValidSquare(start : int, xslide : int, yslide : int) -> bool: # Check if movement is within bounds of game
	var displacement = start + xslide + (yslide * 8)
	if not displacement in range(0,64):
		return false
	if not start % 8 + xslide in range(0,8):
		return false
	return true

func getMoveDisplacement(start : int, xslide : int, yslide : int) -> int: # Give the end index for xslide and yslide
	return start + xslide + (yslide * 8)

func isFriendlyPiece(piece : String, white : bool) -> bool:
	if piece == "":
		return false
	return (piece.to_lower() == piece) == not white
	
func isEnemyPiece(piece : String, white : bool) -> bool:
	if piece == "":
		return false
	return (piece.to_lower() == piece) == white
