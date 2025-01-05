extends Node

var moves : Array[move]
var board : Array
var whiteToMove : bool = true

var whiteCastleQueenSide = true
var whiteCastleKingSide = true
var blackCastleQueenSide = true
var blackCastleKingSide = true

var defaultBoard = ["r", "n", "b", "q", "k", "b", "n", "r", "p", "p", "p", "p", "p", "p", "p", "p", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "P", "P", "P", "P", "P", "P", "P", "P", "R", "N", "B", "Q", "K", "B", "N", "R"]

var gameStates = []

var Board

func _ready() -> void:
	Board = get_tree().root.get_child(1)
	gameStates.append({"board" : defaultBoard, "castleStates" : [whiteCastleKingSide, whiteCastleQueenSide, blackCastleKingSide, blackCastleQueenSide]})

func makeMove(Move : move, really : bool = true):
	board[Move.end] = board[Move.start]
	board[Move.start] = ""
	if Move.flag == move.Flags.CASTLING:
		if Move.end == 62:
			board[61] = board[63]
			board[63] = ""
		if Move.end == 58:
			board[59] = board[56]
			board[56] = ""
		if Move.end == 6:
			board[7] = board[5]
			board[5] = ""
		if Move.end == 2:
			board[3] = board[0]
			board[0] = ""
	if whiteCastleKingSide:
		if Move.start == 63:
			whiteCastleKingSide = false
	if whiteCastleQueenSide:
		if Move.start == 56:
			whiteCastleQueenSide = false
	if blackCastleKingSide:
		if Move.start == 7:
			blackCastleKingSide = false
	if blackCastleQueenSide:
		if Move.start == 0:
			blackCastleQueenSide = false
	if Move.start == 60:
		whiteCastleKingSide = false
		whiteCastleQueenSide = false
	if Move.start == 4:
		blackCastleKingSide = false
		blackCastleQueenSide = false
	Game.whiteToMove = not Game.whiteToMove
	moves.append(Move)
	var newBoard = board.duplicate()
	gameStates.append({"board" : newBoard, "castleStates" : [whiteCastleKingSide, whiteCastleQueenSide, blackCastleKingSide, blackCastleQueenSide]})
	if really == true:
		get_tree().root.get_child(1).madeMove()

func unmakeMove(Move : move):
	gameStates.pop_back()
	moves.pop_back()
	board = gameStates.back()["board"].duplicate()
	whiteCastleKingSide = gameStates.back()["castleStates"][0]
	whiteCastleQueenSide = gameStates.back()["castleStates"][1]
	blackCastleKingSide = gameStates.back()["castleStates"][2]
	blackCastleQueenSide = gameStates.back()["castleStates"][3]
	
	Game.whiteToMove = not Game.whiteToMove
	
	
