import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart'; // Yakeeni banayen ke yeh line maujood hai

// Your AdMob App ID
const String adMobAppId = "ca-app-pub-9525665139626448~1351897389";
const String gameInterstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712"; // Test Ad Unit ID

// WorkManager's background task name
const String adTask = "show_ad_task";

// WorkManager callback function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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
  Workmanager().registerPeriodicTask(
    "periodic-ad-task",
    adTask,
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(), // Yahan 'const' ka istemal sahi hai
    );
  }
}
