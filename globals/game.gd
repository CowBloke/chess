extends Node

var moves : Array[move]
var board : Array
var whiteToMove : bool = true
var wPlayer : String = "Human"
var bPlayer : String = "firstbot"


var whiteCastleQueenSide = true
var whiteCastleKingSide = true
var blackCastleQueenSide = true
var blackCastleKingSide = true

var white_pawns = 0xff00
var white_rooks = 0x81
var white_knights = 0x42
var white_bishops = 0x24
var white_queen = 0x8
var white_king = 0x10
var white_pieces = white_pawns | white_rooks | white_knights | white_bishops | white_queen | white_king

var black_pawns = 0xff000000000000
var black_rooks = 0x81000000000000
var black_knights = 0x4200000000000000
var black_bishops = 0x2400000000000000
var black_queen = 0x800000000000000
var black_king = 0x1000000000000000
var black_pieces = black_pawns | black_rooks | black_knights | black_bishops | black_queen | black_king

var all_pieces = white_pieces|black_pieces
var empty_squares = ~all_pieces

var w_attack_squares = 0b0
var castleState = 0b1111
var castleMasks = [0b0111, 0b1011, 0b1101, 0b1110]

var defaultBoard = ["r", "n", "b", "q", "k", "b", "n", "r", "p", "p", "p", "p", "p", "p", "p", "p", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "P", "P", "P", "P", "P", "P", "P", "P", "R", "N", "B", "Q", "K", "B", "N", "R"]
var startingPos = "rn1qkb1r/1pp1pppp/p4n2/3p1b2/3P4/2P2NP1/PP2PP1P/RNBQKB1R w KQkq - 0 1"
var startingFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

var gameStates = []

var Board

var captureCount = 0

func setup() -> void:
	Board = get_tree().root.get_child(1)
	if startingPos == "default":
		parseFen(startingFen)
		gameStates.append({"board" : board.duplicate(), "castleState" : castleState})
	else:
		parseFen(startingPos)
		gameStates.append({"board" : board.duplicate(), "castleState" : castleState})
	

func makeMove(Move : move, actual_move : bool = true):
	var startSquare = Move.getStart()
	var endSquare = Move.getEnd()
	captureCount += 1 # 50 captureless move rule
	if not board[endSquare] == "":
		captureCount = 0
	else:
		if captureCount == 50:
			return
	board[endSquare] = board[startSquare]
	board[startSquare] = ""
	if Move.getFlag() == move.Flags.KNIGHT_PROMOTE:
		board[endSquare] = "N" if whiteToMove else "n"
	if Move.getFlag() == move.Flags.BISHOP_PROMOTE:
		board[endSquare] = "B" if whiteToMove else "b"
	if Move.getFlag() == move.Flags.ROOK_PROMOTE:
		board[endSquare] = "R" if whiteToMove else "r"
	if Move.getFlag() == move.Flags.QUEEN_PROMOTE:
		board[endSquare] = "Q" if whiteToMove else "q"
	if Move.getFlag() == move.Flags.CASTLING:
		if endSquare == 62:
			board[61] = board[63]
			board[63] = ""
		if endSquare == 58:
			board[59] = board[56]
			board[56] = ""
		if endSquare == 6:
			board[7] = board[5]
			board[5] = ""
		if endSquare == 2:
			board[3] = board[0]
			board[0] = ""
	if whiteCastleKingSide:
		if startSquare == 63:
			castleState & castleMasks[0]
	if whiteCastleQueenSide:
		if startSquare == 56:
			castleState & castleMasks[1]
	if blackCastleKingSide:
		if startSquare == 7:
			castleState & castleMasks[2]
	if blackCastleQueenSide:
		if startSquare == 0:
			castleState & castleMasks[3]
	if startSquare == 60:
		castleState & castleMasks[0]
		castleState & castleMasks[1]
	if startSquare == 4:
		castleState & castleMasks[2]
		castleState & castleMasks[3]
	Game.whiteToMove = not Game.whiteToMove
	moves.append(Move)
	var newBoard = board.duplicate()
	gameStates.append({"board" : newBoard, "castleState" : castleState})
	if actual_move == true:
		get_tree().root.get_child(1).madeMove()

func unmakeMove(Move : move):
	if captureCount > 0:
		captureCount -= 1
	gameStates.pop_back()
	moves.pop_back()
	board = gameStates.back()["board"].duplicate()
	castleState = gameStates.back()["castleState"]
	Game.whiteToMove = not Game.whiteToMove
	
func parseFen(fen : String) -> void:
	var parsed = fen.split(" ")
	# Board
	for i in range(64):
		board.append("")
	startingPos = parsed[0]
	var currentpiece = 0
	var lines = startingPos.split("/")
	print(lines)
	for i in lines:
		var letters = i.split() if len(i) > 1 else i
		for j in letters:
			if j.is_valid_int():
				currentpiece += int(j)
			else:
				board[currentpiece] = j
				currentpiece += 1
	print(currentpiece)
	# Who to play
	whiteToMove = parsed[1] == "w"
	# Castling rights
	castleState = 0b0
	if "K" in parsed[1]:
		castleState | (0b1 << 3)
	if "Q" in parsed[1]:
		castleState | (0b1 << 2)
	if "k" in parsed[1]:
		castleState | (0b1 << 1)
	if "q" in parsed[1]:
		castleState | (0b1)
	# En passant
	
	
	# Half moves
