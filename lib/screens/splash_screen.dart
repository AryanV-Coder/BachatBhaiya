import 'package:flutter/material.dart';
import '../services/gameplay_service.dart';
import 'game_screen.dart';

/// Simple splash/loading screen that runs any "startup" API calls
/// and shows a percent-based progress indicator.  Once the work is
/// finished it replaces itself with the real [GameScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GameplayService _gameplayService = GameplayService();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // start the initialization after the first frame so that context is
    // available for navigation if needed.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadResources());
  }

  Future<void> _loadResources() async {
    // list every async operation that has to be done before the game
    // can be used without delays.  Add/remove items as your API grows.
    final List<Future> tasks = [
      // a dummy request just to warm up the backend with sensible
      // default parameters; real parameters may come from persisted state
      _gameplayService.fetchGameplay(role: 'Farmer', level: 1, totalCoins: 0),
      // the advice endpoint is fairly cheap but we can call it too
      _gameplayService.fetchBachatBhaiyaAdvice(
        role: 'Farmer',
        previousLevel: 0,
        currentCoins: 0,
        previousLevelGraph: {},
      ),
    ];

    // run all futures in parallel but update progress as each completes
    var completed = 0;
    await Future.wait(tasks.map((task) async {
      try {
        await task;
      } catch (_) {
        // swallow startup errors – we still want to advance the bar
      }
      completed++;
      if (mounted) {
        setState(() {
          _progress = completed / tasks.length;
        });
      }
    }));

    // small delay so the user can see 100% briefly if the requests were
    // extremely fast; keeps the UI from jumping too abruptly.
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).clamp(0, 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF68B1E), // orange-ish
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/bachatBhaiya.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 8,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Bachat Bhaiya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Laying the foundation for SITARA World.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
