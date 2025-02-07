



using ChessEngine;
using System;
using Godot;

namespace ChessEngine
{
    public class ChessBoard
    {
        public Piece[] Board { get; private set; }
        public bool WhiteToMove;

        public ChessBoard()
        {
            Board = new Piece[64];
        }

        public void MakeMove(Move move)
        {
            Board[move.end] = Board[move.start];
            Board[move.start] = Piece.Null;

            WhiteToMove = !WhiteToMove;
        }
    }
}