using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChessGUI
{
    class GraphicalBoard
    {
        public List<ColorRect> squares = new List<ColorRect>();

        // Colors for the board, primary starts at top left
        Color primaryColor = new(0.969f, 0.908f, 0.874f);
        Color secondaryColor = new(0.665f, 0.442f, 0.308f);

        // Create the graphical board
        public void CreateGraphicalBoard(Node GuiManager)
        {
            Control SquareGrid = GuiManager.GetNode<Control>($"../SquareGrid");
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


        // Highlighting a specific square on the board with a color and intensity
        public void highlightSquare(int square, Color color, float intensity)
        {
            var file = square % 8;
            var rank = 7 - (int)Math.Floor(square / 8.0);
            squares[file + rank*8].Color = squares[square].Color.Lerp(color, intensity);
        }


    }
}
