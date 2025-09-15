import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final List<List<Color>> board;
  final List<Color> colors;

  GamePainter({required this.board, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    // Game board dimensions and bubble properties
    final double bubbleRadius = 25.0;
    final double padding = 5.0;
    final int rows = board.length;
    final int cols = board[0].length;
    final double bubbleDiameter = bubbleRadius * 2;
    final double totalWidth = cols * bubbleDiameter + (cols - 1) * padding;
    final double totalHeight = rows * bubbleDiameter + (rows - 1) * padding;
    final double startX = (size.width - totalWidth) / 2;
    final double startY = (size.height - totalHeight) / 2;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double x = startX + c * (bubbleDiameter + padding) + bubbleRadius;
        final double y = startY + r * (bubbleDiameter + padding) + bubbleRadius;
        final Color color = board[r][c];

        // Draw the bubble
        final Paint paint = Paint()..color = color;
        canvas.drawCircle(Offset(x, y), bubbleRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
