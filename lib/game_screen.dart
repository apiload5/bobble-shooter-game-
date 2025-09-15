// File: lib/game_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'game_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state variables
  static const int rows = 12;
  static const int cols = 8;
  static const double bubbleRadius = 25.0;
  late List<List<Color>> board;
  final List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple, Colors.orange,];
  int score = 0;
  bool isGameOver = false;

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  Timer? _adSkipTimer;
  int _adTimeLeft = 5;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _loadInterstitialAd();
  }

  void _initializeGame() {
    board = List.generate(
      rows,
      (_) => List.generate(
        cols,
        (_) => colors[Random().nextInt(colors.length)],
      ),
    );
    score = 0;
    isGameOver = false;
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: gameInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _restartGame();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              _restartGame();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          // Agar ad load na ho to game seedha restart ho jaye
          if (isGameOver) {
            _restartGame();
          }
        },
      ),
    );
  }

  void _showAdWithSkip() {
    // Agar ad load ho to ad screen show karein
    if (_isAdLoaded) {
      _adTimeLeft = 5;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              _adSkipTimer?.cancel();
              _adSkipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (_adTimeLeft > 0) {
                  setState(() {
                    _adTimeLeft--;
                  });
                } else {
                  timer.cancel();
                }
              });

              return AlertDialog(
                title: const Text('Ad'),
                content: const Text('Ad is playing...'),
                actions: [
                  if (_adTimeLeft > 0)
                    Text('Skip in $_adTimeLeft'),
                  if (_adTimeLeft <= 0)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _interstitialAd?.show();
                      },
                      child: const Text('Skip Ad'),
                    ),
                ],
              );
            },
          );
        },
      ).then((_) => _restartGame()); // Dialog band hone par game restart karein
    } else {
      // Agar ad load na ho to seedha game restart karein
      _restartGame();
    }
  }

  void _endGame() {
    setState(() {
      isGameOver = true;
    });
    _showAdWithSkip();
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
      isGameOver = false;
    });
    // Nay ad load karein agle game ke liye
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _adSkipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bobble Shooter'),
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: GamePainter(board: board, colors: colors),
            child: GestureDetector(
              onTapUp: (details) {
                setState(() {
                  score += 10;
                  if (score >= 100 && !isGameOver) {
                    _endGame();
                  }
                });
              },
            ),
          ),
          if (isGameOver)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Game Over', style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold)),
                  Text('Final Score: $score', style: const TextStyle(fontSize: 20, color: Colors.black)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _restartGame,
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// GamePainter class code yahan se shamil karen
// ...
