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
    // References to the square and piece objects
    List<ColorRect> squares = new List<ColorRect>();
    List<TextureRect> pieces = new List<TextureRect>();

    // Colors for the board, primary starts at top left
    Color primaryColor = new(0.969f, 0.908f, 0.874f);
    Color secondaryColor = new(0.665f, 0.442f, 0.308f);

    // Create the main instance of the ChessBoard, used throughout the program
    ChessBoard board = new ChessBoard();
    MoveGenerator MoveGenerator = new MoveGenerator();
    FenParser fenParser = new FenParser();

    // Dictionary to map the piece number to the texture name in the texture folder
    readonly System.Collections.Generic.Dictionary<int, string> pieceToTexture = new()
    {
        { 1, "bP" }, { 2, "bN" }, { 3, "bB" }, { 4, "bR" }, { 5, "bQ" }, { 6, "bK" },
        { 9, "wP" }, { 10, "wN" }, { 11, "wB" }, { 12, "wR" }, { 13, "wQ" }, { 14, "wK" }
    };


    // Ready function called at beginning
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

    // Setup the board squares
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

    // Setup the pieces on the board
    public void setupPieces()
    {
        Control PieceGrid = GetNode<Control>($"../PieceGrid");
        var gridNumber = 0;
        foreach (var piece in board.Board)
        {
            if (piece == 0) {gridNumber++;continue; } // Skipping if the square is empty
            var pieceObject = new Piece(piece);
            var pieceSprite = new TextureRect();
            // Loading the texture for the piece, refer to the dictionary above
            pieceSprite.Texture = (Texture2D)ResourceLoader.Load("res://pieces/" + pieceToTexture[pieceObject.PieceData] + ".png");
            pieceSprite.Position = new Vector2(50 * ((float)gridNumber%8), 50 * (7-(float)Math.Floor(gridNumber/ 8.0))); 
            pieceSprite.Position += new Vector2(5, 5); // Small offset to center the piece
            pieceSprite.CustomMinimumSize = new Vector2(40, 40);
            pieceSprite.TextureFilter = CanvasItem.TextureFilterEnum.Nearest; // Makes the filter look neat for the pixelated piece textures
            PieceGrid.AddChild(pieceSprite);
            gridNumber++;
        }
    }

    // Highlighting a specific square on the board with a color and intensity
    public void highlightSquare(int square, Color color, float intensity)
    {
        squares[square].Color = squares[square].Color.Lerp(color, intensity);
    }
}



