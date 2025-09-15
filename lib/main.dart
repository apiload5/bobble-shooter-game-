import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

// Your AdMob App ID
const String adMobAppId = "ca-app-pub-9525665139626448~1351897389";
const String gameInterstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712"; // Test Ad Unit ID

// WorkManager's background task name
const String adTask = "show_ad_task";

// WorkManager callback function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Implement logic to show ad
    // NOTE: Direct UI interaction is not possible from a background task.
    // This task is meant to signal the app to show an ad when it's active.
    // We will use a flag in shared preferences for this.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showAdNow', true);
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  runApp(const MyApp());
  _scheduleAdTask();
}

void _scheduleAdTask() {
  Workmanager().registerPeriodicTask(
    "periodic-ad-task",
    adTask,
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _checkAndShowAd();
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAndShowAd();
    });
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
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _checkAndShowAd() async {
    final prefs = await SharedPreferences.getInstance();
    bool showAd = prefs.getBool('showAdNow') ?? false;
    if (showAd && _isAdLoaded) {
      _interstitialAd?.show();
      await prefs.setBool('showAdNow', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const GameScreen(),
    );
  }
}

// Yahan par baaki game screen ka code
// (lib/game_screen.dart file se)
// ...
