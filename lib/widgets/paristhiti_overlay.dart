import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../services/gameplay_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ParisthitiOverlay extends StatefulWidget {
  final PlayerModel player;
  final VoidCallback onQuit;
  final VoidCallback onUpdate;

  const ParisthitiOverlay({
    super.key,
    required this.player,
    required this.onQuit,
    required this.onUpdate,
  });

  @override
  State<ParisthitiOverlay> createState() => _ParisthitiOverlayState();
}

class _ParisthitiOverlayState extends State<ParisthitiOverlay> {
  final GameplayService _gameplayService = GameplayService();

  bool _showIntroPopup = true;
  bool _isLoading = false;
  bool _showSituation = false;
  bool _showAdvice = false;

  List<GameNode> _nodes = [];
  GameNode? _currentNode;
  int _totalCoinImpact = 0;
  Map<String, dynamic>? _gameGraphData;

  String? _bachatBhaiyaAdvice;

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
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),

            if (!_showIntroPopup &&
                _showSituation &&
                !_showAdvice &&
                _currentNode != null)
              _buildNodeInterface(),

            if (_showAdvice && _bachatBhaiyaAdvice != null)
              _buildAdviceScreen(),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),

            if (_showIntroPopup) _buildIntroDialog(),
          ],
        ),
      ),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'PARISTHITI AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B6914),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready for a new Paristhiti?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: widget.onQuit,
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _startParisthiti,
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startParisthiti() async {
    setState(() {
      _showIntroPopup = false;
      _isLoading = true;
    });

    try {
      final response = await _gameplayService.fetchGameplay(
        role: 'farmer',
        level: widget.player.level,
        totalCoins: widget.player.totalBalance,
      );

      // Build game graph data for later use
      final nodesJson = response.nodes
          .map((node) => {
                'node_id': node.nodeId,
                'scenario': node.scenario,
                'choices': node.choices
                    .map((choice) => {
                          'choice_text': choice.choiceText,
                          'coin_impact': choice.coinImpact,
                          'next_node_id': choice.nextNodeId,
                        })
                    .toList(),
              })
          .toList();

      setState(() {
        _isLoading = false;
        _nodes = response.nodes;
        _currentNode = _nodes.isNotEmpty ? _nodes.first : null;
        _gameGraphData = {
          'nodes': nodesJson,
          'optimal_path': response.optimalPath,
        };
        _showSituation = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showIntroPopup = true; // Go back to intro on error
      });
      // Handle error, perhaps show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load gameplay: $e')),
      );
    }
  }

  Widget _buildNodeInterface() {
    return Center(
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber, width: 6),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAMEPLAY SCENARIO',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B6914),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _currentNode!.scenario,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.4),
              ),
              const SizedBox(height: 30),
              ..._currentNode!.choices.map((choice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => _selectChoice(choice),
                    child: Text(
                      choice.choiceText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ).animate().fadeIn().scale(),
    );
  }

  void _selectChoice(GameChoice choice) {
    setState(() {
      _totalCoinImpact += choice.coinImpact;
      if (choice.nextNodeId == 'success' || choice.nextNodeId == 'failure') {
        // update balance and fetch advice
        widget.player.totalBalance += _totalCoinImpact;
        widget.onUpdate();
        _fetchBachatBhaiyaAdvice();
      } else {
        _currentNode = _nodes.firstWhere((node) => node.nodeId == choice.nextNodeId);
      }
    });
  }

  Future<void> _fetchBachatBhaiyaAdvice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_gameGraphData == null) {
        throw Exception('Game graph data not available');
      }

      final advice = await _gameplayService.fetchBachatBhaiyaAdvice(
        role: 'farmer',
        previousLevel: widget.player.level,
        currentCoins: widget.player.totalBalance,
        previousLevelGraph: _gameGraphData!,
      );

      setState(() {
        _isLoading = false;
        _bachatBhaiyaAdvice = advice.advice;
        _showAdvice = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load advice: $e')),
      );
    }
  }


  Widget _buildAdviceScreen() {
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
            // Left: Bachat Bhaiya (Integrated Character)
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
            // Right: Advice Content
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
                            const Text(
                              'Bachat Bhaiya\'s Advice',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B6914),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _bachatBhaiyaAdvice ?? '',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
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
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _finishLevel,
                      child: const Text(
                        'UNDERSTAND & CONTINUE',
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

  void _finishLevel() {
    widget.onQuit();
  }
}
