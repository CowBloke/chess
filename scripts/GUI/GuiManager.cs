using Godot;
using System;
using ChessEngine;
using System.Collections.Generic;
using System.Linq;
using Godot.NativeInterop;
using Godot.Collections;
using System.Data.SqlTypes;
using System.Threading.Tasks;

namespace ChessGUI
{
    public partial class GuiManager : Node
    {
        // References to the square and piece objects
        List<TextureRect> pieces = new List<TextureRect>();

        // Create the main instance of the ChessBoard, used throughout the program
        public ChessBoard board = new ChessBoard();
        public MoveGenerator MoveGenerator = new MoveGenerator();
        public FenParser fenParser = new FenParser();
        public PieceManager PieceManager = new PieceManager();
        GraphicalBoard GraphicalBoard = new GraphicalBoard();

        public Move[] latestMoves = System.Array.Empty<Move>();


        // Ready function called at beginning
        public override void _Ready()
        {
            //Create the board squares
            GraphicalBoard.CreateGraphicalBoard(this);
            PrecomputedMoveData.PrecomputeMoveData();

            board = fenParser.ParseFen(FenParser.startingFen); // Use the type name to call startingFen

            // Spawning the pieces on the board
            PieceManager.SetupPieces(this, board);

            Move[] moves = MoveGenerator.GenerateMoves(board);
            latestMoves = moves;
        }

        public void ProcessMove(Move move)
        {
            GetNode<SoundManager>($"../SoundManager").PlaySound(SoundManager.Sounds.Move);
            board.MakeMove(move);

            GraphicalBoard.highlightSquare(move.start, new Color(0.929f, 0.855f, 0.176f), 0.5f);
            GraphicalBoard.highlightSquare(move.end, new Color(0.929f, 0.855f, 0.176f), 0.5f);


            Move[] moves = MoveGenerator.GenerateMoves(board);
            latestMoves = moves;
        }

        public Move[] GetMoves()
        {
            return latestMoves;
        }


    }
}



