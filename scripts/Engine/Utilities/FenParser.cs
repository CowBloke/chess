using Godot;
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

        readonly Dictionary<string, Piece> pieces = new Dictionary<string, Piece>
                {
                    { "p", Piece.BlackPawn },
                    { "n", Piece.BlackKnight },
                    { "b", Piece.BlackBishop },
                    { "r", Piece.BlackRook },
                    { "q", Piece.BlackQueen },
                    { "k", Piece.BlackKing },

                    { "P", Piece.WhitePawn },
                    { "N", Piece.WhiteKnight },
                    { "B", Piece.WhiteBishop },
                    { "R", Piece.WhiteRook },
                    { "Q", Piece.WhiteQueen },
                    { "K", Piece.WhiteKing }
                };

        public ChessBoard ParseFen(string FenString)
        {
            ChessBoard board = new ChessBoard();
            // Fill the board with empty pieces
            for (int i = 0; i < 64; i++)
            {
                board.Board[i] = Piece.Null;
            }
            string[] parts = FenString.Split(' ');

            // Parse the pieces
            int line = 0;
            int index = 0;
            string[] boardfen = parts[0].Split('/').Reverse().ToArray();
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

            // Parse the side to move
            board.WhiteToMove = parts[1] == "w";
            return board;
        }

        
    }
}
