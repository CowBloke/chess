using Godot;
using System;
using ChessEngine;
using System.Collections.Generic;
using System.Linq;
using Godot.NativeInterop;
using Godot.Collections;
using System.Data.SqlTypes;

public partial class GuiManager : Node
{

    List<ColorRect> squares = new List<ColorRect>();

    // Colors for the board, first starts at top left
    Color primaryColor = new(0.969f, 0.908f, 0.874f);
    Color secondaryColor = new(0.969f, 0.908f, 0.874f);

    ChessBoard board = new ChessBoard(); // Create the main instance of the ChessBoard
    MoveGenerator MoveGenerator = new MoveGenerator(); // Create a movegenerator
    FenParser fenParser = new FenParser(); // Create an instance of FenParser

    public override void _Ready()
    {
        setupBoardSquares();
        PrecomputedMoveData.PrecomputeMoveData();
        board = fenParser.ParseFen(FenParser.startingFen); // Use the type name to call startingFen

    }

    public void setupBoardSquares()
    {
        Control SquareGrid = GetNode<Control>($"../SquareGrid");
        for (int i = 0; i < 64; i++)
        {
            var square = new ColorRect();
            squares.Add(square);
            square.Color = (i % 2 == 0) ? primaryColor : secondaryColor;
            square.SizeFlagsHorizontal = Control.SizeFlags.Fill;
            square.SizeFlagsVertical = Control.SizeFlags.Fill;
            GD.Print("hello");
            SquareGrid.AddChild(square);
        }
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
