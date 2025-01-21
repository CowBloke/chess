using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChessEngine
{
    public class PrecomputedMoveData
    {

        public static readonly int[] DirectionOffsets = { -9, -8, -7, -1, 1, 7, 8, 9 };
        public static readonly int[] KnightOffsets = { -17, -15, -10, -6, 6, 10, 15, 17 };

        public static readonly byte[][] knightMoves = new byte[64][];

        internal static void PrecomputeMoveData()
        {
            for (int square = 0; square < 64; square++)
            {

                List<byte> LegalKnightMoves = new();
                foreach (int offset in KnightOffsets)
                {
                    int target = square + offset;
                    if (target >= 0 && target < 64)
                    {
                        if (Math.Abs(square % 8 - target % 8) <= 2)
                        {
                            LegalKnightMoves.Add((byte)target);
                        }
                    }
                }
                knightMoves[square] = LegalKnightMoves.ToArray();

            }
        }
    }
}