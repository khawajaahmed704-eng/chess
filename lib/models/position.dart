class Position {
  final int row; // 0 to 7 (0 is rank 8, 7 is rank 1)
  final int col; // 0 to 7 (0 is file 'a', 7 is file 'h')

  const Position(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  String get algebraic {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return '$file$rank';
  }

  static Position? fromAlgebraic(String alg) {
    if (alg.length != 2) return null;
    final col = alg.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.tryParse(alg[1]);
    if (rank == null || rank < 1 || rank > 8 || col < 0 || col > 7) return null;
    return Position(8 - rank, col);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($algebraic: $row,$col)';
}
