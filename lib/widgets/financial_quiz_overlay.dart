import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../services/paristhiti_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FinancialQuizOverlay extends StatefulWidget {
  final PlayerModel player;
  final VoidCallback onQuit;
  final VoidCallback onUpdate;

  const FinancialQuizOverlay({
    super.key,
    required this.player,
    required this.onQuit,
    required this.onUpdate,
  });

  @override
  State<FinancialQuizOverlay> createState() => _FinancialQuizOverlayState();
}

class _FinancialQuizOverlayState extends State<FinancialQuizOverlay> {
  final ParisthitiService _service = ParisthitiService();

  bool _showIntroPopup = true;
  bool _isLoading = false;

  int _sessionEarnedCoins = 0;
  int _questionsAskedInSession = 0;
  final int _maxQuestionsPerSession = 5;

  ParisthitiQuestion? _currentQuestion;
  bool _hasAnswered = false;
  int? _selectedOptionIndex;

  bool _showSummary = false;
  Map<String, String>? _summaryData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        // Keep it safe from HUD boundaries somewhat
        child: Stack(
          children: [
            // Dark overlay to make things readable
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),

            // Core Quiz Interface
            if (!_showIntroPopup && _currentQuestion != null && !_showSummary)
              _buildQuizInterface(),

            // Summary Screen
            if (_showSummary && _summaryData != null) _buildSummaryScreen(),

            // Loading Spinner
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),

            // Introduction Dialog
            if (_showIntroPopup) _buildIntroDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryScreen() {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        width: size.width * 0.85,
        height: size.height * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber, width: 6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Bachat Bhaiya
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Image.asset(
                  'assets/images/bachatBhaiya.png',
                  fit: BoxFit.contain,
                ).animate().fadeIn(duration: 600.ms),
              ),
            ),
            // Right: Summary Content
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _summaryData!['summary']!,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                _summaryData!['rbiGuideline']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blue.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _showFinishDialog,
                      child: const Text(
                        'FINISH',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ],
        ),
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildIntroDialog() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDDE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDCC8A0), width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology, size: 60, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'VILLAGE QUIZ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B6914),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready for a session of 5 questions?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _getSessionCostText(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: widget.onQuit,
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _startFetchingQuestion,
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSessionCostText() {
    if (widget.player.paristhitiQuestionsAsked < 5) {
      return 'First 5 questions are free!\nCorrect answers earn 50 coins.';
    } else {
      return 'Each question now costs 20 coins.\nTotal session cost: 100 coins.';
    }
  }

  Future<void> _startFetchingQuestion() async {
    if (widget.player.paristhitiQuestionsAsked >= 5) {
      if (widget.player.totalBalance < 20) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Not enough coins!'),
            content: const Text(
              'You need 20 coins to continue with the next question.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showFinishDialog();
                },
                child: const Text('Finish Session'),
              ),
            ],
          ),
        );
        return;
      } else {
        setState(() {
          widget.player.totalBalance -= 20;
        });
        widget.onUpdate();
      }
    }

    widget.player.paristhitiQuestionsAsked++;
    _questionsAskedInSession++;

    setState(() {
      _showIntroPopup = false;
      _isLoading = true;
      _hasAnswered = false;
      _selectedOptionIndex = null;
    });

    final question = await _service.fetchQuizQuestion();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentQuestion = question;
      });
    }
  }

  Widget _buildQuizInterface() {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 10,
                bottom: 40,
                child: Image.asset(
                  _currentQuestion!.speakerImagePath,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

              Positioned(
                right: 10,
                bottom: 40,
                child: Transform.flip(
                  flipX: true,
                  child: Image.asset(
                    'assets/images/farmer.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Container(
                width: 480,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Question $_questionsAskedInSession of $_maxQuestionsPerSession',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentQuestion!.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: List.generate(
                          _currentQuestion!.options.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: _buildOptionButton(
                                index,
                                _currentQuestion!.options[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_hasAnswered)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Center(
                            child: Text(
                              'Earned: $_sessionEarnedCoins',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, String text) {
    Color btnColor = Colors.grey.shade200;
    Color textColor = Colors.black87;

    if (_hasAnswered) {
      if (index == _currentQuestion!.correctOptionIndex) {
        btnColor = Colors.green;
        textColor = Colors.white;
      } else if (index == _selectedOptionIndex) {
        btnColor = Colors.red;
        textColor = Colors.white;
      }
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: _hasAnswered ? 0 : 2,
      ),
      onPressed: _hasAnswered ? null : () => _handleAnswer(index),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight:
              _hasAnswered && index == _currentQuestion!.correctOptionIndex
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  void _handleAnswer(int selectedIndex) {
    if (_hasAnswered) return;
    setState(() {
      _hasAnswered = true;
      _selectedOptionIndex = selectedIndex;

      if (selectedIndex == _currentQuestion!.correctOptionIndex) {
        _sessionEarnedCoins += 50;
      } else {
        // Penalty logic for paid questions (after first 5)
        if (widget.player.paristhitiQuestionsAsked > 5) {
          _sessionEarnedCoins -= 10;
        }
      }
    });

    // Auto-advance after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_questionsAskedInSession < _maxQuestionsPerSession) {
          _startFetchingQuestion();
        } else {
          _showSummaryScreen();
        }
      }
    });
  }

  Future<void> _showSummaryScreen() async {
    setState(() {
      _isLoading = true;
    });

    final summary = await _service.fetchSummary(_sessionEarnedCoins ~/ 50);

    setState(() {
      _isLoading = false;
      _showSummary = true;
      _summaryData = summary;
    });

    // Simulate audio triggering
    debugPrint(
      'Playing audio: ${summary['summary']} ${summary['rbiGuideline']}',
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Session Finished!'),
        content: Text(
          'Total earnings this session: $_sessionEarnedCoins coins\n\nWhere should we deposit them?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                widget.player.totalBalance += _sessionEarnedCoins;
              });
              widget.onUpdate();
              Navigator.pop(context); // Close dialog
              widget.onQuit(); // Exit Paristhiti mode
            },
            child: const Text(
              'Total Balance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Emergency fund is now an absolute value, add coins directly
                widget.player.emergencyFund += _sessionEarnedCoins;
              });
              widget.onUpdate();
              Navigator.pop(context); // Close dialog
              widget.onQuit(); // Exit Paristhiti mode
            },
            child: const Text(
              'Emergency Fund',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
