import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Bobble Shooter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameScreen(),
    );
  }
}

// GameScreen class ab stateful hai
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  static const int rows = 12; // Mazeed rows
  static const int cols = 8;
  static const double bubbleRadius = 25.0;

  late List<List<Color>> board;
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  late Color currentShooterBubble;
  late Offset shooterPosition;
  late Offset shooterBubblePosition;
  late Offset shooterBubbleVelocity;

  late AnimationController _controller;
  int score = 0;
  bool isShooting = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
      if (isShooting) {
        _updateShooterBubble();
      }
    });
  }

  void _initializeGame() {
    board = List.generate(
      rows,
      (_) => List.generate(
        cols,
        (_) => colors[Random().nextInt(colors.length)],
      ),
    );
    currentShooterBubble = colors[Random().nextInt(colors.length)];
    shooterPosition = const Offset(0, 0);
    shooterBubblePosition = const Offset(0, 0);
    shooterBubbleVelocity = const Offset(0, 0);
    score = 0;
    isShooting = false;
  }

  void _handleTap(TapDownDetails details, Size size) {
    if (isShooting) return;

    final tapPosition = details.localPosition;
    final shooterCenter = Offset(size.width / 2, size.height - 50);

    // Shooter bubble ko tap ki direction mein shoot karwana
    final angle = atan2(tapPosition.dy - shooterCenter.dy, tapPosition.dx - shooterCenter.dx);

    setState(() {
      isShooting = true;
      shooterBubblePosition = shooterCenter;
      shooterBubbleVelocity = Offset(cos(angle) * 10, sin(angle) * 10);
      _controller.forward(from: 0);
    });
  }

  void _updateShooterBubble() {
    shooterBubblePosition += shooterBubbleVelocity;

    // Boundary collision
    if (shooterBubblePosition.dx < bubbleRadius || shooterBubblePosition.dx > MediaQuery.of(context).size.width - bubbleRadius) {
      shooterBubbleVelocity = Offset(-shooterBubbleVelocity.dx, shooterBubbleVelocity.dy);
    }
    if (shooterBubblePosition.dy < bubbleRadius) {
      _stopShooting();
      return;
    }

    // Board collision
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final bubbleX = c * (bubbleRadius * 2) + bubbleRadius;
        final bubbleY = r * (bubbleRadius * 2) + bubbleRadius;
        final dist = sqrt(pow(shooterBubblePosition.dx - bubbleX, 2) + pow(shooterBubblePosition.dy - bubbleY, 2));

        if (board[r][c] != Colors.transparent && dist < bubbleRadius * 2) {
          // Bubble se takrane ke baad shooter bubble ko board par add kar dein
          _addBubbleToBoard(r, c);
          return;
        }
      }
    }
    setState(() {});
  }

  void _addBubbleToBoard(int row, int col) {
    // Shooter bubble ko board mein nearest empty spot par add karein
    // Yeh logic abhi simplified hai. Aap isko mazeed behtar bana sakte hain.
    board[row][col] = currentShooterBubble;

    // Match find karein
    Set<List<int>> matches = _findMatches(row, col, currentShooterBubble);

    if (matches.length >= 3) {
      setState(() {
        for (var match in matches) {
          board[match[0]][match[1]] = Colors.transparent;
          score += 10; // Score add karein
        }
      });
    }

    // Next shooter bubble generate karein aur shooting state reset karein
    _stopShooting();
  }

  void _stopShooting() {
    isShooting = false;
    currentShooterBubble = colors[Random().nextInt(colors.length)];
    _controller.reset();
    setState(() {});
  }

  Set<List<int>> _findMatches(int row, int col, Color color) {
    final Set<List<int>> matches = {};
    final List<List<int>> queue = [[row, col]];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final r = current[0];
      final c = current[1];

      if (r < 0 || r >= rows || c < 0 || c >= cols || board[r][c] != color) {
        continue;
      }
      if (!matches.any((m) => m[0] == r && m[1] == c)) {
        matches.add([r, c]);
        queue.add([r + 1, c]);
        queue.add([r - 1, c]);
        queue.add([r, c + 1]);
        queue.add([r, c - 1]);
      }
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Bobble Shooter'),
      ),
      body: GestureDetector(
        onTapDown: (details) => _handleTap(details, MediaQuery.of(context).size),
        child: CustomPaint(
          size: Size.infinite,
          painter: GamePainter(
            board: board,
            colors: colors,
            bubbleRadius: bubbleRadius,
            shooterBubblePosition: isShooting ? shooterBubblePosition : null,
            shooterBubbleColor: currentShooterBubble,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              height: bubbleRadius * 2,
              width: bubbleRadius * 2,
              decoration: BoxDecoration(
                color: currentShooterBubble,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// CustomPainter class
class GamePainter extends CustomPainter {
  final List<List<Color>> board;
  final List<Color> colors;
  final double bubbleRadius;
  final Offset? shooterBubblePosition;
  final Color shooterBubbleColor;

  GamePainter({
    required this.board,
    required this.colors,
    required this.bubbleRadius,
    this.shooterBubblePosition,
    required this.shooterBubbleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Board ke bubbles ko draw karein
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[0].length; c++) {
        if (board[r][c] != Colors.transparent) {
          final bubbleX = c * (bubbleRadius * 2) + bubbleRadius;
          final bubbleY = r * (bubbleRadius * 2) + bubbleRadius;
          final paint = Paint()..color = board[r][c];
          canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleRadius, paint);
        }
      }
    }

    // Shooter bubble ko draw karein
    if (shooterBubblePosition != null) {
      final paint = Paint()..color = shooterBubbleColor;
      canvas.drawCircle(shooterBubblePosition!, bubbleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
