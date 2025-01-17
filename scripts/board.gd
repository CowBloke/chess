extends Control

@export var color_1 : Color = Color(0.969, 0.908, 0.874)
@export var color_2 : Color = Color(0.665, 0.442, 0.308)

var squares : Array[ColorRect] = []
var overlays : Array[ColorRect] = []
var squarecolors : Array[int] = []
var counter = 0

var promotionChosen : bool = false
var promotionChoice


var bot : Node
var bot2 : Node

var board = []

const pieceConversionTable = {"p": 0b0001,"n": 0b0010,"b": 0b0011, "r": 0b0100,"q": 0b0101,"k": 0b0110,"P": 0b1001,"N": 0b1010,"B": 0b1011, "R": 0b1100,"Q": 0b1101,"K": 0b1110}
const reversepieceConversionTable = {0b0001: "p",0b0010: "n",0b0011: "b", 0b0100: "r",0b0101 : "q",0b0110: "k",0b1001: "P",0b1010: "N",0b1011: "B", 0b1100: "R", 0b1101:"Q",0b1110 : "K"}

var moveSound
var captureSound
var checkSound
var castleSound

func _ready() -> void:
	createBoard()
	moveSound = $Sounds/Move
	captureSound = $Sounds/Capture
	checkSound = $Sounds/Check
	castleSound = $Sounds/Castle
	loadBots()
	loadPieces()
	await get_tree().create_timer(0.5).timeout
	#for i in range(4):
		#var ms = Time.get_ticks_msec()
		#print($BasicLogic.CountPossibleNodes(i+1), "  ", Time.get_ticks_msec()-ms)
	if not Game.wPlayer == "Human":
		madeMove()
	
func loadBots():
	bot = $Bot
	bot2 = $Bot2
	if not Game.wPlayer == "Human":
		var botscript = load("res://bots/"+ Game.wPlayer +".gd")
		bot.set_script(botscript)
	if not Game.bPlayer == "Human":
		var botscript = load("res://bots/"+ Game.bPlayer +".gd")
		bot2.set_script(botscript)
	
			
func madeMove():
	if len(Game.moves) > 0:
		$"Last Move".text = "Last move : " + Game.convertNumberToSquare(Game.moves[len(Game.moves)-1].getStart()) + Game.convertNumberToSquare(Game.moves[len(Game.moves)-1].getEnd())
	if $BasicLogic.isCheckmate(not Game.whiteToMove):
			$Result.text = "Checkmate " + Game.bPlayer + " wins"
			$Result.show()
			return
	if $BasicLogic.isCheckmate(Game.whiteToMove):
			$Result.text = "Checkmate " + Game.wPlayer + " wins"
			$Result.show()
			return
	
	if not (Game.wPlayer if Game.whiteToMove else Game.bPlayer) == "Human": 
		if (Game.bPlayer if Game.whiteToMove else Game.wPlayer) == "Human":
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(0).timeout
		var botMove : move = bot.returnMove($BasicLogic) if Game.whiteToMove else bot2.returnMove($BasicLogic)
		var piece = searchForPieceAt(botMove.getStart())
		await piece.movePieceFrom(botMove.getEnd(), false, true)
		await piece.processMove()
		loadPieces()
			
		

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
		originalSquareColor(Game.moves[len(Game.moves)-1].getStart())
		originalSquareColor(Game.moves[len(Game.moves)-1].getEnd())
	
	if not Game.board[currentmove.getEnd()] == 0 or currentmove.getFlag() == move.Flags.ENPASSANT:
		soundtype = "capture"
		Game.board[currentmove.getEnd()] = 0
		var piece = searchForPieceAt(currentmove.getEnd())
		if currentmove.getFlag() == move.Flags.ENPASSANT:
			if floor(currentmove.getEnd() / 8) == 2:
				piece = searchForPieceAt(currentmove.getEnd()+8)
				piece.deleteAtSquare()
			else:
				piece = searchForPieceAt(currentmove.getEnd()-8)
				piece.deleteAtSquare()
	else:
		if currentmove.getFlag() == move.Flags.CASTLING:
			soundtype = "castle"
			if currentmove.getStart() == 60: # For white castling
				if currentmove.getEnd() == 62: # King Side
					var piece = searchForPieceAt(63)
					piece.movePieceFrom(61, true, true)
				if currentmove.getEnd() == 58: # Queen Side
					var piece = searchForPieceAt(56)
					piece.movePieceFrom(59, true, true)
			if currentmove.getStart() == 4: # For black castling
				if currentmove.getEnd() == 6: # King Side
					var piece = searchForPieceAt(7)
					piece.movePieceFrom(5, true, true)
				if currentmove.getEnd() == 2: # Queen Side
					var piece = searchForPieceAt(0)
					piece.movePieceFrom(3, true, true)
		else:
			soundtype = "move"
	
	#if currentmove.getFlag() == move.Flags.QUEEN_PROMOTE:
		#var text = (load("res://pieces/wQ.png") if Game.whiteToMove else load("res://pieces/bQ.png"))
		#changePieceTexture(currentmove.getEnd(), text)
	#if currentmove.getFlag() == move.Flags.ROOK_PROMOTE:
		#var text = (load("res://pieces/wR.png") if Game.whiteToMove else load("res://pieces/bR.png"))
		#changePieceTexture(currentmove.getEnd(), text)
	#if currentmove.getFlag() == move.Flags.BISHOP_PROMOTE:
		#var text = (load("res://pieces/wB.png") if Game.whiteToMove else load("res://pieces/bB.png"))
		#changePieceTexture(currentmove.getEnd(), text)
	#if currentmove.getFlag() == move.Flags.KNIGHT_PROMOTE:
		#var text = (load("res://pieces/wN.png") if Game.whiteToMove else load("res://pieces/bN.png"))
		#changePieceTexture(currentmove.getEnd(), text)

		
	changeSquareColor(currentmove.getEnd(), Color("#edda2d"))
	changeSquareColor(currentmove.getStart(), Color("#edda2d"))
	
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
		if i.getStart() == square:
			changeSquareColor(i.getEnd(), Color("#F74328"))
			
func hideMovesForPiece(square : int):
	for i in $BasicLogic.GenerateLegalMoves(Game.whiteToMove):
		if i.getStart() == square:
			originalSquareColor(i.getEnd())

func loadPieces():
	deleteAllPieces()
	var currentpiece = -1
	for i in Game.board:
		currentpiece += 1
		if i == 0:
			pass
		else:
			placeAt(reversepieceConversionTable[i], currentpiece)

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

func returnPromotion():
	print("promoting")
	$PromotionChoice.visible = true
	await promotionChosen == true
	$PromotionChoice.visible = false
	return promotionChoice


func capturePieceAt(number : int):
	for i in $PieceGrid.get_children():
		i.deleteAtSquare(number)

func searchForPieceAt(number : int):
	for i in $PieceGrid.get_children():
		var pieceref = i.returnPieceReference(number)
		if not pieceref == null:
			return pieceref
	return null

func _on_line_edit_text_submitted(new_text: String) -> void:
	loadPieces()

func changeSquareColor(square : int, newcolor : Color):
	squares[square].color = squares[square].color.lerp(newcolor, 0.5)

func originalSquareColor(square : int):
	squares[square].color = color_1 if squarecolors[square] == 0 else color_2





# Overlay Code

func clearOverlay():
	for i in $OverlayGrid.get_children():
		i.color = Color("#ff000000")

func _process(delta: float) -> void:
	if len(overlays) == 64 and len (Game.board) == 64:
		if $Attack.button_pressed:
			attackOverlay()
		elif $Pieces.button_pressed:
			pieceOverlay()
		else:
			clearOverlay()

func pieceOverlay():
	for i in range(len(overlays)):
		if not Game.board[i] == 0:
			overlays[i].color = Color("#0000ff5d")
		else:
			overlays[i].color = Color("#ff000000")
			
func attackOverlay():
	var attacks = $BasicLogic.GenerateAttackSquares(Game.whiteToMove)
	clearOverlay()
	for i in attacks:
		overlays[i].color = Color("#ff7a006c")


func _on_queen_pressed() -> void:
	promotionChoice = "Q" if Game.whiteToMove else "q"
	promotionChosen = true

func _on_rook_pressed() -> void:
	promotionChoice = "R" if Game.whiteToMove else "r"
	promotionChosen = true

func _on_bishop_pressed() -> void:
	promotionChoice = "B" if Game.whiteToMove else "b"
	promotionChosen = true

func _on_knight_pressed() -> void:
	promotionChoice = "N" if Game.whiteToMove else "n"
	promotionChosen = true
