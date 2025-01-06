extends TextureRect

var originalPos : Vector2
var showmoves = false

func update() -> void:
	originalPos = global_position

func _gui_input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var root = get_tree().root.get_child(1)
		if showmoves == false:
			root.showMovesForPiece(GetSquareNb(originalPos))
			showmoves = true
		global_position = get_global_mouse_position() - Vector2(20,20)
		move_to_front()

	elif event is InputEventMouseButton and not event.pressed:
		processMove()

func processMove():
		var root = get_tree().root.get_child(1)
		var nextSquare = GetSquareNb(global_position)
		var isSquareValid = false
		var moveData : move
		for i in root.getMoves():
			if i.getStart() == GetSquareNb(originalPos) and i.getEnd() == nextSquare:
				isSquareValid = true
				moveData = i
				
				break
		if not isSquareValid:
			global_position = originalPos
			showmoves = false
			
			root.hideMovesForPiece(GetSquareNb(originalPos))
		else:
			global_position = snap_to_grid(global_position)
			
			showmoves = false
			
			root.hideMovesForPiece(GetSquareNb(originalPos))
			
			if moveData.getFlag() == move.Flags.KNIGHT_PROMOTE or moveData.getFlag() == move.Flags.BISHOP_PROMOTE or moveData.getFlag() == move.Flags.ROOK_PROMOTE or moveData.getFlag() == move.Flags.QUEEN_PROMOTE:
				if (Game.wPlayer if Game.whiteToMove else Game.bPlayer) == "Human":
					#var chosenPromotion = root.returnPromotion().lower()
					#var promotiontable = {"q" : move.Flags.QUEEN_PROMOTE, "r" : move.Flags.ROOK_PROMOTE, "b" : move.Flags.BISHOP_PROMOTE, "n" : move.Flags.KNIGHT_PROMOTE}
					#moveData.movedata = (moveData.movedata >> 4 << 4 )|promotiontable[chosenPromotion]
					texture = load("res://pieces/wQ.png")
					
					
			root.processMove(moveData)
			originalPos = global_position

func GetSquareNb(pos : Vector2):
	pos = snap_to_grid(pos)
	pos -= Vector2(205, 45)
	return (pos.x/50) + ((pos.y/50)*8)
	
func returnSquareFromNumber(square : int):
	var pos : Vector2 = Vector2(0,0)
	pos += Vector2(205, 45)
	pos.x += (square % 8) * 50
	pos.y += floor(square / 8) * 50
	return pos

func deleteAtSquare(number : int):
	if number == GetSquareNb(originalPos):
		hide()
		
func changeTexture(number : int, texture : Texture):
	if number == GetSquareNb(global_position):
		texture = texture
	
func movePieceFrom(number : int, number2 : int, _keepGlobalPos = false, tween : bool = false):
	if GetSquareNb(global_position) == number:
		if _keepGlobalPos:
			originalPos = returnSquareFromNumber(number2)
		if tween:
			var tween_ = create_tween()
			tween_.tween_property(self, "global_position", returnSquareFromNumber(number2), 0.1)
		else:
			global_position = returnSquareFromNumber(number2)
		
		

func snap_to_grid(pos: Vector2):
	pos -= Vector2(200, 40)
	pos = Vector2(round((pos.x)/ 50) * 50,round((pos.y)/ 50) * 50)
	pos += Vector2(205, 45)
	return pos
	
func returnPieceReference(number : int):
	if GetSquareNb(originalPos) == number:
		return self
	else:
		return null
