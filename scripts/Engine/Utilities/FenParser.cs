using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChessEngine
{
    public class FenParser
    {

        public const string startingFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

        readonly Dictionary<string, int> pieces = new Dictionary<string, int>
                {
                    { "p", 1 },
                    { "n", 2 },
                    { "b", 3 },
                    { "r", 4 },
                    { "q", 5 },
                    { "k", 6 },
                    { "P", 9 },
                    { "N", 10 },
                    { "B", 11 },
                    { "R", 12 },
                    { "Q", 13 },
                    { "K", 14 }
                };

        public ChessBoard ParseFen(string FenString)
        {
            ChessBoard board = new ChessBoard();
            string[] parts = FenString.Split(' ');

            // Parse the pieces
            int line = 0;
            int index = 0;
            string[] boardfen = parts[0].Split('/');

            // Parsing Board
            foreach (string row in boardfen)
            {
                foreach (char symbol in row)
                {
                    if (char.IsDigit(symbol))
                    {
                        index += (int)char.GetNumericValue(symbol);
                    }
                    else
                    {
                        board.Board[index] = pieces[symbol.ToString()];
                        index++;
                    }

                }
                line++;
                index = line * 8;
            }

            return board;
        }
    }
}
