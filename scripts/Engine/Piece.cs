using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChessEngine
{
    public class Piece
    {
        public enum PieceType
        {
            Pawn,
            Knight,
            Bishop,
            Rook,
            Queen,
            King
        }

        public Piece(int pieceData) => PieceData = pieceData;
        public Piece(PieceType pieceType, bool white)
        {
            PieceData = (int)pieceType | (white ? 8 : 0);
        }

        public int PieceData { get; private set; }

        public PieceType GetPieceType() => (PieceType)(PieceData & 7);
        public bool isFriendlyPiece(bool white) => ((PieceData >> 3) == (white ? 1 : 0)) && PieceData != 0;
        public bool isEnemyPiece(bool white) => ((PieceData >> 3) == (white ? 0 : 1)) && PieceData != 0;
    }
}
