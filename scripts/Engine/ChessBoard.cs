



using ChessEngine;
using System;
using Godot;

namespace ChessEngine
{
    public class ChessBoard
    {
        public int[] Board { get; private set; }
        public bool WhiteToMove;

        public ChessBoard()
        {
            Board = new int[64];
        }
    }
}