using Godot;
using System;
using ChessEngine;
using System.Collections.Generic;
using System.Linq;
using Godot.NativeInterop;
using Godot.Collections;

public partial class GodotBridge : Node
{
    ChessBoard board = new ChessBoard(); // Create the main instance of the ChessBoard
    MoveGenerator MoveGenerator = new MoveGenerator(); // Create a movegenerator
    FenParser fenParser = new FenParser(); // Create an instance of FenParser

    public override void _Ready()
    {
        PrecomputedMoveData.PrecomputeMoveData();
        board = fenParser.ParseFen(FenParser.startingFen); // Use the type name to call startingFen

    }


    public Godot.Collections.Array<int> GetMoves()
    {
        var moves = MoveGenerator.GenerateMoves(board);
        Godot.Collections.Array<int> moveDataList = new Godot.Collections.Array<int>(); 

        foreach (var move in moves)
        {
            moveDataList.Add(move.Data); 
        }

        return moveDataList;
    }
}
