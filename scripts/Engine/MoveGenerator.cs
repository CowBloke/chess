using ChessEngine;
using System;
using System.Collections.Generic;
using Godot;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.CompilerServices;
using static Godot.TextServer;


namespace ChessEngine
{
    public class MoveGenerator
    {
        private int pieceRank(int square) => (int)Math.Floor(square / 8.0);
        private int pieceFile(int square) => square % 8;

        // Main movement generation
        Move[] moves = new Move[218];
        int moveCount = 0;

        public Move[] GenerateMoves(ChessBoard board)
        {
            moveCount = 0;
            GeneratePawnMoves(board);
            GenerateKnightMoves(board);
            Move[] result = new Move[moveCount];
            Array.Copy(moves, result, moveCount);
            return result;
        }

        public void GeneratePawnMoves(ChessBoard board)
        {
            int direction = board.WhiteToMove ? 8 : -8;

            for (int i = 0; i < 64; i++)
            {
                Piece piece = board.Board[i];
                if (piece.isFriendlyPiece(board.WhiteToMove) & piece.GetPieceType() == Piece.PieceType.Pawn) {
                    int target = i + direction;
                    if (board.Board[target] == Piece.Null)
                    {
                        // Single push
                        if (pieceRank(target) == (board.WhiteToMove ? 7 : 0))
                        {
                            moves[moveCount++] = new Move(i, target, Move.MoveFlags.QueenPromotion);
                            moves[moveCount++] = new Move(i, target, Move.MoveFlags.KnightPromotion);
                            moves[moveCount++] = new Move(i, target, Move.MoveFlags.BishopPromotion);
                            moves[moveCount++] = new Move(i, target, Move.MoveFlags.RookPromotion);
                        }
                        else
                        {
                            moves[moveCount++] = new Move(i, target);
                        }

                        // Double push
                        if (pieceRank(i) == (board.WhiteToMove ? 1 : 6))
                        {
                            int doublePushTarget = i + 2 * direction;
                            if (board.Board[doublePushTarget] == Piece.Null)
                                moves[moveCount++] = new Move(i, doublePushTarget);
                        }
                    }
                }
            }
        }
        public void GenerateKnightMoves(ChessBoard board)
        {
            for (int i = 0; i < 64; i++)
            {
                Piece piece = board.Board[i];
                if (piece.isFriendlyPiece(board.WhiteToMove) & (piece.GetPieceType() == Piece.PieceType.Knight))
                {
                    foreach (int target in PrecomputedMoveData.knightMoves[i])
                    {
                        Piece targetPiece = board.Board[target];
                        if (targetPiece.isFriendlyPiece(board.WhiteToMove)) continue;
                        moves[moveCount++] = new Move(i, target);
                    }
                }
            }
        }
    }
}