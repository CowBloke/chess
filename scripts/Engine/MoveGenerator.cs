using ChessEngine;
using System;
using System.Collections.Generic;
using Godot;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.CompilerServices;


namespace ChessEngine
{
    public class MoveGenerator
    {

        private int pieceRank(int square) => (int)Math.Round(square / 8.0);
        private int pieceFile(int square) => square % 8;


        // Main movement generation
        List<Move> moves;
        public List<Move> GenerateMoves(ChessBoard board)
        {
            GeneratePawnMoves(board);
            return moves;
        }

        public List<Move> GeneratePawnMoves(ChessBoard board)
        {
            List<Move> moves = new();
            int direction = board.WhiteToMove ? 8 : -8;

            for (int i = 0; i < 64; i++)
            {
                int piece = board.Board[i];
                if (piece != 0) continue;

                int target = i + direction;
                if (board.Board[target] == 0)
                {
                    // Single push
                    if (pieceRank(target) == (board.WhiteToMove ? 7 : 0))
                    {
                        moves.Add(new Move(i, target, Move.MoveFlags.QueenPromotion));
                        moves.Add(new Move(i, target, Move.MoveFlags.KnightPromotion));
                        moves.Add(new Move(i, target, Move.MoveFlags.BishopPromotion));
                        moves.Add(new Move(i, target, Move.MoveFlags.RookPromotion));
                    }
                    else
                    {
                        moves.Add(new Move(i, target));
                    }

                    // Double push
                    if (pieceRank(i) == (board.WhiteToMove ? 1 : 6))
                    {
                        int doublePushTarget = i + 2 * direction;
                        if (board.Board[doublePushTarget] == 0)
                            moves.Add(new Move(i, doublePushTarget));
                    }
                }
            }


            return moves;
        }
    }
}