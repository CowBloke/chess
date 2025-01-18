namespace ChessEngine
{
	[Flags]
	public enum MoveFlags : byte
	{
		None = 0,
		Capture = 1 << 0,
		EnPassant = 1 << 1,
		Castling = 1 << 2,
		Promotion = 1 << 3
	}

	public struct Move
	{
		private readonly ushort data;

		public Move(ushort encodedMove) => data = encodedMove;

		public Move(int source, int destination, MoveFlags flags)
		{
			data = (ushort)((source & 0x3F) | ((destination & 0x3F) << 6) | ((int)flags << 12));
		}

		public int SourceSquare => data & 0x3F;
		public int DestinationSquare => (data >> 6) & 0x3F;
		public MoveFlags Flags => (MoveFlags)((data >> 12) & 0xF);

		public override string ToString() =>
			$"Source: {SourceSquare}, Destination: {DestinationSquare}, Flags: {Flags}";
	}
}
