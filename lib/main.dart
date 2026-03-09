import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape — game maps are always wider than they are tall
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]); 

  // Full-screen immersive mode (hides status bar & navigation bar)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const SiTaraApp());
}

class SiTaraApp extends StatelessWidget {
  const SiTaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiTARA World',
      debugShowCheckedModeBanner: false,
      // Use a game-appropriate theme with no elevation/shadows on buttons
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // Remove default splash ink effects — we have custom animations
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const SplashScreen(),
    );
  }
}