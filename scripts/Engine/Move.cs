 namespace ChessEngine
{
	public enum MoveFlags : byte
	{
		None,
		Capture,
		EnPassant,
		Castling,
		Promotion
	}

	public struct Move
	{
		private readonly ushort data;

		public enum MoveFlags : int
        {
            None = 0b0000,
            Capture = 0b0001,
            EnPassant = 0b0010,
            Castling = 0b0011,

            KnightPromotion = 0b0100,
            BishopPromotion = 0b0101,
            RookPromotion = 0b0110,
            QueenPromotion = 0b0111
        }

        public Move(ushort encodedMove) => data = encodedMove;

		public Move(int source, int destination) => data = (ushort)((source & 0x3F) | ((destination & 0x3F) << 6));

        public Move(int source, int destination, MoveFlags flags) => data = (ushort)((source & 0x3F) | ((destination & 0x3F) << 6) | ((int)flags << 12));

		public int SourceSquare => data & 0x3F;
		public int DestinationSquare => (data >> 6) & 0x3F;
		public int Data => data;
        public MoveFlags Flags => (MoveFlags)((data >> 12) & 0xF);

		public override string ToString() =>
			$"Source: {SourceSquare}, Destination: {DestinationSquare}, Flags: {Flags}";
	}
}
