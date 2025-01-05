extends Control

@export var color_1 : Color = Color(0.969, 0.908, 0.874)
@export var color_2 : Color = Color(0.665, 0.442, 0.308)

var squares : Array[ColorRect] = []
var overlays : Array[ColorRect] = []
var squarecolors : Array[int] = []
var counter = 0

var opponent = "firstbot"

var bot : Node

var board = []

#const pieceConversionTable = {"p": 0b0001,"n": 0b0010,"b": 0b0011, "r": 0b0100,"q": 0b0101,"k": 0b0110,"P": 0b1001,"N": 0b1010,"B": 0b1011, "R": 0b1100,"Q": 0b1101,"K": 0b1110}

var moveSound
var captureSound
var checkSound
var castleSound

func _ready() -> void:
	for i in range(64):
		Game.board.append("")
	createBoard()
	moveSound = $Sounds/Move
	captureSound = $Sounds/Capture
	checkSound = $Sounds/Check
	castleSound = $Sounds/Castle
	bot = $Bot
	loadBot(opponent)
	loadFromFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
	await get_tree().create_timer(0.5).timeout
	#for i in range(4):
		#var ms = Time.get_ticks_msec()
		#print($BasicLogic.CountPossibleNodes(i+1), "  ", Time.get_ticks_msec()-ms)
	
func loadBot(botToLoad : String):
	var botscript = load("res://bots/"+ botToLoad +".gd")
	bot.set_script(botscript)
			
func madeMove():
	$"Last Move".text = "Last move : " + convertNumberToSquare(Game.moves[len(Game.moves)-1].start) + convertNumberToSquare(Game.moves[len(Game.moves)-1].end)
	if not Game.whiteToMove: 
		if $BasicLogic.isCheckmate(Game.whiteToMove):
			$Result.show()
		else:
			var botMove : move = bot.returnMove($BasicLogic)
			await get_tree().create_timer(0.2).timeout
			movePieceFrom(botMove.start, botMove.end, true)
			await get_tree().create_timer(0.1).timeout
			if not searchForPieceAt(botMove.start) == null:
				searchForPieceAt(botMove.start).processMove()
		

func createBoard() -> void:
	for i in range(4):
		for j in range(8):
			var square = returnSquare(1) if j%2 == 0 else returnSquare(2)
			var overlay = returnSquare(3)
			squarecolors.append(0 if j%2 == 0 else 1)
			$SquareGrid.add_child(square)
			$OverlayGrid.add_child(overlay)
			squares.append(square)
			overlays.append(overlay)
		for j in range(8):
			var square = returnSquare(2) if j%2 == 0 else returnSquare(1)
			var overlay = returnSquare(3)
			squarecolors.append(1 if j%2 == 0 else 0)
			$SquareGrid.add_child(square)
			$OverlayGrid.add_child(overlay)
			squares.append(square)
			overlays.append(overlay)

func GetSquareNb(pos : Vector2):
	pos = snap_to_grid(pos)
	pos -= Vector2(560, 140)
	return pos.x/100 + ((pos.y/100)*8)

func snap_to_grid(pos: Vector2):
	pos -= Vector2(560, 140)
	pos = Vector2(round((pos.x)/ 100) * 100,round((pos.y)/ 100) * 100)
	pos += Vector2(560, 140)
	return pos

func processMove(currentmove : move):
	var soundtype = "move"
	if not Game.moves.is_empty():
		originalSquareColor(Game.moves[len(Game.moves)-1].start)
		originalSquareColor(Game.moves[len(Game.moves)-1].end)
	
	if not Game.board[currentmove.end] == "" or currentmove.flag == move.Flags.ENPASSANT:
		soundtype = "capture"
		Game.board[currentmove.end] = ""
		capturePieceAt(currentmove.end)
		if currentmove.flag == move.Flags.ENPASSANT:
			if currentmove.end % 8 == 2:
				capturePieceAt(currentmove.end+8)
			else:
				capturePieceAt(currentmove.end-8)
	else:
		if currentmove.flag == move.Flags.CASTLING:
			soundtype = "castle"
			if currentmove.start == 60: # For white castling
				if currentmove.end == 62: # King Side
					movePieceFrom(63, 61)
				if currentmove.end == 58: # Queen Side
					movePieceFrom(56, 59)
			if currentmove.start == 4: # For black castling
				if currentmove.end == 6: # King Side
					movePieceFrom(7, 5)
				if currentmove.end == 2: # Queen Side
					movePieceFrom(0, 3)
		else:
			soundtype = "move"
		
	changeSquareColor(currentmove.end, Color("#edda2d"))
	changeSquareColor(currentmove.start, Color("#edda2d"))
	
	Game.makeMove(currentmove)
	
	if $BasicLogic.isCheck(not Game.whiteToMove):
		soundtype = "check"
	
	if soundtype == "check":
		checkSound.play()
		#print(convertNumberToSquare(currentmove.start), convertNumberToSquare(currentmove.end))
	elif soundtype == "capture":
		captureSound.play()
	elif soundtype == "castle":
		castleSound.play()
	elif soundtype == "move":
		moveSound.play()
	

func returnSquare(type) -> ColorRect:
	var colorRect : ColorRect = ColorRect.new()
	colorRect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	colorRect.size_flags_vertical = Control.SIZE_EXPAND_FILL

	if type == 1:
		colorRect.color = color_1
		return colorRect
	elif type == 2:
		colorRect.color = color_2
		return colorRect
	else:
		colorRect.color = Color("#ff00003d")
		return colorRect
		
func getMoves():
	return $BasicLogic.GenerateLegalMoves(Game.whiteToMove)

func deleteAllPieces() -> void:
	for i in $PieceGrid.get_children():
		i.queue_free()

func showMovesForPiece(square : int):
	for i in $BasicLogic.GenerateLegalMoves(Game.whiteToMove):
		if i.start == square:
			changeSquareColor(i.end, Color("#ff0000"))
			
func hideMovesForPiece(square : int):
	for i in $BasicLogic.GenerateLegalMoves(Game.whiteToMove):
		if i.start == square:
			originalSquareColor(i.end)

func loadFromFen(fen_string : String):
	deleteAllPieces()
	var currentpiece = 0
	var lines = fen_string.split("/")
	for i in lines:
		var letters = i.split() if len(i) > 1 else i
		for j in letters:
			if j.is_valid_int():
				currentpiece += int(j)
			else:
				placeAt(j, currentpiece)
				Game.board[currentpiece] = j
				currentpiece += 1

func placeAt(type : String, number : int):
	var coordinates = Vector2i(205 + ((number % 8)*50), 45 + (floor(number/8)*50))
	var piece = TextureRect.new()
	$PieceGrid.add_child(piece)
	if type.to_lower() == type:
		piece.texture = load("res://pieces/b"+type.to_upper()+".png")
	else:
		piece.texture = load("res://pieces/w"+type.to_upper ()+".png")
	piece.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	piece.set_script(load("res://scripts/piece.gd"))
	piece.custom_minimum_size = Vector2i(40, 40)
	piece.global_position = coordinates
	piece.update()

func capturePieceAt(number : int):
	for i in $PieceGrid.get_children():
		i.deleteAtSquare(number)

func searchForPieceAt(number : int):
	for i in $PieceGrid.get_children():
		if not i.returnPieceReference(number) == null:
			return i.returnPieceReference(number)
	return null

func _on_line_edit_text_submitted(new_text: String) -> void:
	loadFromFen(new_text)

func movePieceFrom(square : int, square2 : int, tween : bool = false):
	for i in $PieceGrid.get_children():
		i.movePieceFrom(square, square2, false, tween)

func changeSquareColor(square : int, newcolor : Color):
	squares[square].color = squares[square].color.lerp(newcolor, 0.5)
	
func originalSquareColor(square : int):
	squares[square].color = color_1 if squarecolors[square] == 0 else color_2

func convertNumberToSquare(number : int):
	var letters = ["a","b","c","d","e","f","g","h"]
	return letters[floor((63 - number)/8)] + str((63 - number)%8+1)



# Overlay Code

func clearOverlay():
	for i in $OverlayGrid.get_children():
		i.color = Color("#ff000000")

func _process(delta: float) -> void:
	if len(overlays) == 64 and len(Game.board) == 64:
		if $Attack.button_pressed:
			attackOverlay()
		elif $Pieces.button_pressed:
			pieceOverlay()
		else:
			clearOverlay()

func pieceOverlay():
	for i in range(len(overlays)):
		if not Game.board[i] == "":
			overlays[i].color = Color("#0000ff5d")
		else:
			overlays[i].color = Color("#ff000000")
			
func attackOverlay():
	var attacks = $BasicLogic.GenerateAttackSquares(Game.whiteToMove)
	clearOverlay()
	for i in attacks:
		overlays[i].color = Color("#ff7a006c")

func _on_button_pressed() -> void:
	pass
