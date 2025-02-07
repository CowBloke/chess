using ChessEngine;
using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChessGUI
{
    public class PieceManager
    {
        // Dictionary to map the piece number to the texture name in the texture folder
        readonly System.Collections.Generic.Dictionary<int, string> pieceToTexture = new()
        {
            { 1, "bP" }, { 2, "bN" }, { 3, "bB" }, { 4, "bR" }, { 5, "bQ" }, { 6, "bK" },
            { 9, "wP" }, { 10, "wN" }, { 11, "wB" }, { 12, "wR" }, { 13, "wQ" }, { 14, "wK" }
        };

        private Vector2 lastPosition ;

        // Setup the pieces on the board
        public void SetupPieces(Node GuiManager, ChessBoard board)
        {
            Control PieceGrid = GuiManager.GetNode<Control>($"../PieceGrid");
            var gridNumber = 0;
            foreach (var piece in board.Board)
            {
                if (piece == Piece.Null) { gridNumber++; continue; } // Skipping if the square is empty
                var pieceSprite = new TextureRect();
                // Loading the texture for the piece, refer to the dictionary above
                pieceSprite.Texture = (Texture2D)ResourceLoader.Load("res://pieces/" + pieceToTexture[piece.PieceData] + ".png");
                pieceSprite.Position = new Vector2(50 * ((float)gridNumber % 8), 50 * (7 - (float)Math.Floor(gridNumber / 8.0)));
                pieceSprite.Position += new Vector2(5, 5); // Small offset to center the piece
                pieceSprite.CustomMinimumSize = new Vector2(40, 40);
                pieceSprite.TextureFilter = CanvasItem.TextureFilterEnum.Nearest; // Makes the filter look neat for the pixelated piece textures
                PieceGrid.AddChild(pieceSprite);
                pieceSprite.GuiInput += (InputEvent @event) => OnPieceGuiInput(@event, pieceSprite);
                pieceSprite.FocusMode = Control.FocusModeEnum.Click;
                gridNumber++;
            }
        }
        // Function to handle the input from the user
        public void OnPieceGuiInput(InputEvent @event, TextureRect piece)
        {
            if (@event is InputEventMouseButton mouseEvent && mouseEvent.Pressed)
            {
                piece.GrabFocus();
                piece.MoveToFront();
                lastPosition = piece.GlobalPosition;
            }
            else if (@event is InputEventMouseMotion mouseMotionEvent && piece.HasFocus())
            {
                piece.GlobalPosition = piece.GetGlobalMousePosition() - Vector2.One * 20;
            }
            else if (@event is InputEventMouseButton mouseEvent2 && !mouseEvent2.Pressed)
            {
                GuiManager guiManager = piece.GetNode<GuiManager>($"../../CSEngine");
                Move[] moves = guiManager.GetMoves();
                Move CurrentMove = new(PositionToSquare(lastPosition), PositionToSquare(piece.GlobalPosition));
                if (moves.Contains(CurrentMove))
                {
                    piece.GlobalPosition = SnapToGrid(piece.GlobalPosition);
                    piece.ReleaseFocus();
                    guiManager.ProcessMove(CurrentMove);
                }
                else
                {
                    piece.GlobalPosition = lastPosition;
                    piece.ReleaseFocus();
                }
            }
        }

        public Vector2 SnapToGrid(Vector2 position)
        {
            position -= new Vector2(205, 30);
            position = new Vector2((float)Math.Round(position.X / 50) * 50, (float)Math.Round(position.Y / 50) * 50);
            return position + new Vector2(205, 30);
        }

        public int PositionToSquare(Vector2 position)
        {
            position -= new Vector2(205, 30);
            position = new Vector2((float)Math.Round(position.X / 50), (float)Math.Round(position.Y / 50));
            return (int)(position.X % 8 + (7 - position.Y) * 8);
        }
    }
}
