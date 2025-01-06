class_name move

@export var movedata : int

func getStart():
	return movedata >> 10
func getEnd():
	return (movedata >> 4) & 0b111111
func getFlag():
	return flaglist[movedata & 0b1111]
func isPromotion():
	return flaglist[movedata & 0b1111] in range(3,7)


var flaglist = [Flags.NONE,Flags.ENPASSANT,Flags.CASTLING,Flags.QUEEN_PROMOTE,Flags.KNIGHT_PROMOTE,Flags.BISHOP_PROMOTE,Flags.ROOK_PROMOTE]
enum Flags {NONE, ENPASSANT, CASTLING, QUEEN_PROMOTE, KNIGHT_PROMOTE, BISHOP_PROMOTE, ROOK_PROMOTE}
