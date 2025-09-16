import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final List<List<Color>> board;

  GamePainter({required this.board});

  @override
  void paint(Canvas canvas, Size size) {
    if (board.isEmpty || board[0].isEmpty) return;

    final double bubbleRadius = 25.0;
    final double padding = 5.0;
    final int rows = board.length;
    final int cols = board[0].length;
    final double bubbleDiameter = bubbleRadius * 2;
    final double totalWidth = cols * bubbleDiameter + (cols - 1) * padding;
    final double totalHeight = rows * bubbleDiameter + (rows - 1) * padding;
    final double startX = (size.width - totalWidth) / 2;
    final double startY = (size.height - totalHeight) / 2;

    final Paint paint = Paint();

    // Optional: background fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        paint.color = board[r][c];
        final double x = startX + c * (bubbleDiameter + padding) + bubbleRadius;
        final double y = startY + r * (bubbleDiameter + padding) + bubbleRadius;
        canvas.drawCircle(Offset(x, y), bubbleRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
