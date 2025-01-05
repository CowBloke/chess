class_name move

@export var start : int
@export var end : int
@export var flag : Flags

enum Flags {NONE, ENPASSANT, CASTLING, QUEEN_PROMOTE, KNIGHT_PROMOTE, BISHOP_PROMOTE, ROOK_PROMOTE}
