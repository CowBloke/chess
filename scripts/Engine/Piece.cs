using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChessEngine
{
    public class Piece
    {
        // Piece Format : CTTT where C is the color bit and TTT it's type

        public enum PieceType
        {
            Null,
            Pawn,
            Knight,
            Bishop,
            Rook,
            Queen,
            King
        }

        //  Constructors
        public Piece(int pieceData) => PieceData = pieceData;
        public Piece(PieceType pieceType, bool white)
        {
            PieceData = (int)pieceType | (white ? 8 : 0);
        }

        // Properties
        public int PieceData { get; private set; }


        // Helper methods
        public PieceType GetPieceType() => (PieceType)(PieceData & 7);
        public int GetPieceNumber() => (PieceData & 7);
        public bool isFriendlyPiece(bool white) => ((PieceData >> 3) == (white ? 1 : 0)) && PieceData != 0;
        public bool isEnemyPiece(bool white) => ((PieceData >> 3) == (white ? 0 : 1)) && PieceData != 0;

        // Template Pieces
        public static Piece Null = new Piece(0);

        public static Piece WhitePawn = new Piece(PieceType.Pawn, true);
        public static Piece WhiteKnight = new Piece(PieceType.Knight, true);
        public static Piece WhiteBishop = new Piece(PieceType.Bishop, true);
        public static Piece WhiteRook = new Piece(PieceType.Rook, true);
        public static Piece WhiteQueen = new Piece(PieceType.Queen, true);
        public static Piece WhiteKing = new Piece(PieceType.King, true);

        public static Piece BlackPawn = new Piece(PieceType.Pawn, false);
        public static Piece BlackKnight = new Piece(PieceType.Knight, false);
        public static Piece BlackBishop = new Piece(PieceType.Bishop, false);
        public static Piece BlackRook = new Piece(PieceType.Rook, false);
        public static Piece BlackQueen = new Piece(PieceType.Queen, false);
        public static Piece BlackKing = new Piece(PieceType.King, false);

    }
}
