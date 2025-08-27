// lib/models/grid_cell.dart
class GridCell {
  final int row;
  final int col;

  GridCell(this.row, this.col);

  @override
  String toString() => 'GridCell(row: $row, col: $col)';
}
