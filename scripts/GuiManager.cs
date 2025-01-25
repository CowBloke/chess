using Godot;
using System;
using ChessEngine;
using System.Collections.Generic;
using System.Linq;
using Godot.NativeInterop;
using Godot.Collections;
using System.Data.SqlTypes;
using System.Threading.Tasks;

public partial class GuiManager : Node
{

    List<ColorRect> squares = new List<ColorRect>();

    // Colors for the board, first starts at top left
    Color primaryColor = new(0.969f, 0.908f, 0.874f);
    Color secondaryColor = new(0.665f, 0.442f, 0.308f);

    ChessBoard board = new ChessBoard(); // Create the main instance of the ChessBoard
    MoveGenerator MoveGenerator = new MoveGenerator(); // Create a movegenerator
    FenParser fenParser = new FenParser(); // Create an instance of FenParser

    readonly System.Collections.Generic.Dictionary<int, string> pieceToTexture = new System.Collections.Generic.Dictionary<int, string>
    {
        { 1, "bP" },
        { 2, "bN" },
        { 3, "bB" },
        { 4, "bR" },
        { 5, "bQ" },
        { 6, "bK" },
        { 9, "wP" },
        { 10, "wN" },
        { 11, "wB" },
        { 12, "wR" },
        { 13, "wQ" },
        { 14, "wK" }
    };



    public override async void _Ready()
    {
        //Create the board squares
        setupBoardSquares();
        PrecomputedMoveData.PrecomputeMoveData();

        board = fenParser.ParseFen(FenParser.startingFen); // Use the type name to call startingFen

        setupPieces();

        Move[] moves = MoveGenerator.GenerateMoves(board);

        GD.Print(moves.Length);

        foreach (var move in moves)
        {
            var initialColor = squares[move.SourceSquare].Color;
            var initialColor2 = squares[move.DestinationSquare].Color;

            highlightSquare(move.SourceSquare, new Color(1.0f, 0.0f, 0.0f), 0.5f);
            await Task.Delay(100);
            highlightSquare(move.DestinationSquare, new Color(1.0f, 0.0f, 0.0f), 0.5f);
            await Task.Delay(500);
            highlightSquare(move.SourceSquare, initialColor, 1.0f);
            highlightSquare(move.DestinationSquare, initialColor2, 1.0f);

        }
    }

    public void setupBoardSquares()
    {
        Control SquareGrid = GetNode<Control>($"../SquareGrid");
        for (int file = 0; file < 8; file++)
        {
            for (int rank = 0; rank < 8; rank++)
            {
                var square = new ColorRect();
                squares.Add(square);
                square.Color = (file + rank) % 2 == 0 ? primaryColor : secondaryColor;
                square.SizeFlagsHorizontal = Control.SizeFlags.Fill;
                square.SizeFlagsVertical = Control.SizeFlags.Fill;
                square.CustomMinimumSize = new Vector2(50, 50);
                SquareGrid.AddChild(square);
            }
        }
    }

    public void setupPieces()
    {
        Control PieceGrid = GetNode<Control>($"../PieceGrid");
        var gridNumber = 0;
        foreach (var piece in board.Board)
        {
            if (piece == 0) {gridNumber++;continue;}
            var pieceObject = new Piece(piece);
            var pieceSprite = new TextureRect();
            pieceSprite.Texture = (Texture2D)ResourceLoader.Load("res://pieces/" + pieceToTexture[pieceObject.PieceData] + ".png");
            pieceSprite.Position = new Vector2(50 * ((float)gridNumber%8), 50 * (7-(float)Math.Floor(gridNumber/ 8.0))); 
            pieceSprite.Position += new Vector2(5, 5);
            pieceSprite.CustomMinimumSize = new Vector2(40, 40);
            pieceSprite.TextureFilter = CanvasItem.TextureFilterEnum.Nearest;
            PieceGrid.AddChild(pieceSprite);
            gridNumber++;
        }
    }

    public void highlightSquare(int square, Color color, float intensity)
    {
        squares[square].Color = squares[square].Color.Lerp(color, intensity);
    }



    public Godot.Collections.Array<int> GetMoves()
    {
        var moves = MoveGenerator.GenerateMoves(board);
        var moveDataList = new System.Collections.Generic.List<int>();

        foreach (var move in moves)
        {
            moveDataList.Add(move.Data);
        }

        var array = new Godot.Collections.Array<int>(moveDataList);
        var testmove = new Move(12, 38);
        moveDataList.Add(testmove.Data);
        return array;
    }
}
