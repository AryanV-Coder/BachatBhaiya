// ════════════════════════════════════════════════════════════════════════════
//  game_screen.dart
//
//  WHAT CHANGED vs the original file:
//  1. Added  `import 'dart:math';`  at the top
//  2. Added three new classes ABOVE GameScreen:
//       • PersonaSelectionScreen   – the character / name-entry UI
//       • _TirangaBackground       – animated saffron/white/green background
//       • _Blob                    – helper circle widget for the background
//  3. Inside _GameScreenState:
//       • `final PlayerModel _player` → `late PlayerModel _player`
//       • Added `bool _showPersonaScreen = true`
//       • initState() now only creates _player; map-centering moved to _centreMap()
//       • Added `void _centreMap()`
//       • build() returns PersonaSelectionScreen first; switches to Scaffold
//         once the player submits their name
//  Everything else is identical to the file you pasted.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../models/player_model.dart';
import '../widgets/hud_bar.dart';
import '../widgets/sidebar_button.dart';
import '../widgets/village_life.dart';
import '../widgets/stock_market_overlay.dart';
import '../widgets/market_stall_widget.dart';
import '../widgets/financial_quiz_overlay.dart';
import '../widgets/paristhiti_overlay.dart';
import '../widgets/storage_overlay.dart';
import '../widgets/profile_overlay.dart';
import '../widgets/chat_overlay.dart';
import '../world/background_world.dart';

// ════════════════════════════════════════════════════════════════════════════
//  ░░  NEW CLASS 1 — PERSONA SELECTION SCREEN  ░░
//  Shown once when the app starts. After the player types a name and taps
//  "Start Adventure", _showPersonaScreen is set to false and GameScreen
//  switches to the actual game world.
// ════════════════════════════════════════════════════════════════════════════

class PersonaSelectionScreen extends StatefulWidget {
  /// Called with the typed player name when "Start Adventure" is tapped.
  final void Function(String playerName) onStart;
  const PersonaSelectionScreen({super.key, required this.onStart});

  @override
  State<PersonaSelectionScreen> createState() =>
      _PersonaSelectionScreenState();
}

class _PersonaSelectionScreenState extends State<PersonaSelectionScreen>
    with TickerProviderStateMixin {
  // ── state ─────────────────────────────────────────────────────────────────
  final TextEditingController _nameCtrl = TextEditingController();
  bool _farmerSelected = true; // only one persona for now

  // ── animation controllers ─────────────────────────────────────────────────
  late final AnimationController _cardPulseCtrl; // border glow on card
  late final AnimationController _floatCtrl;     // farmer image bobs up/down
  late final AnimationController _bgCtrl;        // background circles drift
  late final AnimationController _tapCtrl;       // card tap bounce
  late final Animation<double> _cardScale;       // scale for tap bounce

  @override
  void initState() {
    super.initState();

    _cardPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // scale: 1 → 1.07 → 0.95 → 1  (elastic bounce feel)
    _cardScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 0.95)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_tapCtrl);

    // Rebuild when user types so the button enables/disables
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardPulseCtrl.dispose();
    _floatCtrl.dispose();
    _bgCtrl.dispose();
    _tapCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // Button is active only when a name has been entered
  bool get _canStart =>
      _farmerSelected && _nameCtrl.text.trim().isNotEmpty;

  void _onCardTap() {
    setState(() => _farmerSelected = true);
    _tapCtrl.forward(from: 0);
  }

  void _onStart() {
    if (_canStart) widget.onStart(_nameCtrl.text.trim());
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Wide layout (landscape / tablet): card on left, form on right
    final isWide = size.width > 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation:
            Listenable.merge([_bgCtrl, _floatCtrl, _cardPulseCtrl]),
        builder: (_, _) {
          return Stack(
            children: [
              // ── Tiranga-inspired animated background ──────────────
              _TirangaBackground(bgAnim: _bgCtrl.value),
              // ── Scrollable content ────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: size.height - 80),
                    child: isWide
                        ? _buildWideLayout()
                        : _buildNarrowLayout(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── layouts ───────────────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        _buildTitle(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(flex: 5, child: _buildCharacterCard()),
            const SizedBox(width: 48),
            Flexible(flex: 6, child: _buildFormPanel()),
          ],
        ),
        const SizedBox(height: 24),
        _buildComingSoon(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        _buildTitle(),
        const SizedBox(height: 28),
        _buildCharacterCard(),
        const SizedBox(height: 12),
        _buildComingSoon(),
        const SizedBox(height: 28),
        _buildFormPanel(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2B1B6B), Color(0xFF1A0F50)],
          ).createShader(bounds),
          child: const Text(
            'Choose Your Character',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'अपना किरदार चुनें',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFE8590C), // saffron-orange
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCard() {
    // Pulse border between two saffron shades
    final pulseColor = Color.lerp(
      const Color(0xFFFF9933),
      const Color(0xFFFF6B00),
      _cardPulseCtrl.value,
    )!;
    // Farmer image bobs up and down
    final floatOffset = sin(_floatCtrl.value * pi) * 8;

    return ScaleTransition(
      scale: _cardScale,
      child: GestureDetector(
        onTap: _onCardTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  _farmerSelected ? pulseColor : Colors.transparent,
              width: _farmerSelected ? 3.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: _farmerSelected
                    ? pulseColor.withOpacity(0.35)
                    : Colors.black.withOpacity(0.12),
                blurRadius: _farmerSelected ? 24 : 10,
                spreadRadius: _farmerSelected ? 2 : 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Floating avatar circle
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4CAF50).withOpacity(0.25),
                        const Color(0xFF8BC34A).withOpacity(0.35),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/farmer.png',
                      width: 72,
                      height: 72,
                      // Fallback if asset not found
                      errorBuilder: (_, _, _) => const Text(
                        '👨‍🌾',
                        style: TextStyle(fontSize: 52),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Farmer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2B1B6B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'किसान',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFE8590C),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Master finances while\nrunning your farm!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF5A5A7A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              // Selected / Select chip
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: _farmerSelected
                      ? const Color(0xFFE8590C)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _farmerSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFE8590C)
                                .withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _farmerSelected
                          ? Icons.check
                          : Icons.touch_app,
                      color: _farmerSelected
                          ? Colors.white
                          : const Color(0xFF888888),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _farmerSelected ? 'Selected' : 'Select',
                      style: TextStyle(
                        color: _farmerSelected
                            ? Colors.white
                            : const Color(0xFF888888),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          const Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2B1B6B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your name will appear in the game.',
            style:
                TextStyle(fontSize: 13, color: Color(0xFF888899)),
          ),
          const SizedBox(height: 14),

          // ── Name text field (empty by default) ──────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2B1B6B),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Enter Your Name',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFE8590C),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onStart(),
            ),
          ),

          const SizedBox(height: 20),

          // ── Starting balance tile ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF5A623), Color(0xFFE8940A)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF5A623).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.25),
                  ),
                  child: const Center(
                    child:
                        Text('🪙', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '40,000 Coins',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Starting balance',
                      style: TextStyle(
                          color: Color(0xFFFFF3CC), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Start Adventure button ───────────────────────────────
          // Fades to 45 % opacity and is non-tappable until name entered
          AnimatedOpacity(
            opacity: _canStart ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 250),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canStart ? _onStart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B1B6B),
                  disabledBackgroundColor: const Color(0xFF2B1B6B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _canStart ? 8 : 0,
                  shadowColor:
                      const Color(0xFF2B1B6B).withOpacity(0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start Adventure',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.play_arrow_rounded,
                        color: Color(0xFFFFD700), size: 26),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: Colors.white.withOpacity(0.8), width: 1.5),
      ),
      child: const Text(
        '👨‍🌾  More characters coming soon!',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF5A5A7A),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ░░  NEW CLASS 2 — TIRANGA BACKGROUND  ░░
// ════════════════════════════════════════════════════════════════════════════

class _TirangaBackground extends StatelessWidget {
  final double bgAnim; // 0.0 → 1.0 from AnimationController
  const _TirangaBackground({required this.bgAnim});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final drift = sin(bgAnim * pi) * 20; // circles drift gently

    return Stack(
      children: [
        // Base gradient: saffron cream → ivory white → pale green
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.45, 0.75, 1.0],
              colors: [
                Color(0xFFFDE8C8),
                Color(0xFFFFF3E0),
                Color(0xFFE8F5E9),
                Color(0xFFD7F0DC),
              ],
            ),
          ),
        ),
        // Saffron blob — top-left
        Positioned(
          top: -60 + drift,
          left: -40,
          child: _Blob(
              size: size.width * 0.55,
              color: const Color(0xFFFF9933).withOpacity(0.18)),
        ),
        // Green blob — bottom-right
        Positioned(
          bottom: -80 - drift,
          right: -60,
          child: _Blob(
              size: size.width * 0.65,
              color: const Color(0xFF138808).withOpacity(0.14)),
        ),
        // White/cream circle — centre
        Positioned(
          top: size.height * 0.3 + drift * 0.5,
          left: size.width * 0.5 - 100,
          child: _Blob(
              size: 200,
              color: Colors.white.withOpacity(0.22)),
        ),
        // Small saffron — bottom-left
        Positioned(
          bottom: 40 + drift,
          left: -20,
          child: _Blob(
              size: 180,
              color: const Color(0xFFFF9933).withOpacity(0.12)),
        ),
        // Small green — top-right
        Positioned(
          top: 40 - drift * 0.5,
          right: -30,
          child: _Blob(
              size: 160,
              color: const Color(0xFF138808).withOpacity(0.12)),
        ),
        // Faint Ashoka Chakra watermark
        Positioned(
          top: size.height * 0.12,
          right: size.width * 0.06,
          child: Opacity(
            opacity: 0.06,
            child: Icon(
              Icons.circle_outlined,
              size: size.width * 0.45,
              color: const Color(0xFF000080),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ░░  NEW CLASS 3 — BLOB HELPER  ░░
// ════════════════════════════════════════════════════════════════════════════

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  GAME SCREEN  ← original class, gated behind PersonaSelectionScreen
//  Only 5 lines changed inside here (marked with  // ← CHANGED)
// ════════════════════════════════════════════════════════════════════════════

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // ← CHANGED: was `final PlayerModel _player = PlayerModel(name: 'Farmer');`
  bool _showPersonaScreen = true;          // ← CHANGED (new line)
  late PlayerModel _player;               // ← CHANGED

  bool _isParisthitiMode = false;
  bool _isQuizMode = false;

  final TransformationController _transformCtrl = TransformationController();

  // ← CHANGED: extracted map-centering into its own method so it can be
  //   called AFTER the persona screen completes (not immediately on init).
  void _centreMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      const initialScale = 0.8;
      final offsetX =
          (AppSizes.worldWidth * initialScale - size.width) / 2;
      final offsetY =
          (AppSizes.worldHeight * initialScale - size.height) / 2;
      _transformCtrl.value = Matrix4.identity()
        ..scale(initialScale, initialScale)
        ..translate(-offsetX / initialScale, -offsetY / initialScale);
    });
  }

  @override
  void initState() {
    super.initState();
    // ← CHANGED: player created here; map centering now happens in _centreMap()
    _player = PlayerModel(name: 'Farmer');
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ← CHANGED: show persona screen until player submits name
    if (_showPersonaScreen) {
      return PersonaSelectionScreen(
        onStart: (playerName) {
          setState(() {
            _player = PlayerModel(name: playerName); // create new player with typed name
            _showPersonaScreen = false;
          });
          _centreMap(); // centre map now that screen size is known
        },
      );
    }

    // ── Everything below is 100 % identical to your original file ──────────
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── LAYER B: 2D-scrollable game world OR Quiz Mode ────────────────────────────
          if (_isQuizMode)
            Positioned.fill(
              child: FinancialQuizOverlay(
                player: _player,
                onQuit: () {
                  setState(() {
                    _isQuizMode = false;
                  });
                },
                onUpdate: () {
                  setState(() {});
                },
              ),
            )
          else if (_isParisthitiMode)
            Positioned.fill(
              child: ParisthitiOverlay(
                player: _player,
                onQuit: () {
                  setState(() {
                    _isParisthitiMode = false;
                  });
                },
                onUpdate: () {
                  setState(() {});
                },
              ),
            )
          else
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                constrained: false,
                boundaryMargin: EdgeInsets.zero,
                minScale: 0.5,
                maxScale: 2.0,
                panAxis: PanAxis.free,
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: AppSizes.worldWidth,
                  height: AppSizes.worldHeight,
                  child: Stack(
                    children: [
                      const BackgroundWorld(),
                      _buildInteractiveLayer(),
                    ],
                  ),
                ),
              ),
            ),

          if (!_isParisthitiMode && !_isQuizMode) _buildHUD(),
          if (!_isParisthitiMode && !_isQuizMode) _buildSidebar(),
          _buildWorldBadge(),
        ],
      ),
    );
  }

  Widget _buildInteractiveLayer() {
    return Stack(
      children: [
        // ── EXTRA HUTS (Village Setting) ──
        Positioned(
          top: 80,
          left: 140,
          child: Image.asset('assets/images/otherHuts.png', width: 220),
        ),
        Positioned(
          top: 250,
          left: 20,
          child: Image.asset('assets/images/otherHuts.png', width: 210),
        ),
        Positioned(
          top: 130,
          left: 530,
          child: Image.asset('assets/images/otherHuts.png', width: 230),
        ),
        Positioned(
          top: 60,
          left: 820,
          child: Image.asset('assets/images/otherHuts.png', width: 200),
        ),
        Positioned(
          top: 380,
          left: 750,
          child: Image.asset('assets/images/otherHuts.png', width: 240),
        ),
        Positioned(
          top: 320,
          left: 1100,
          child: Image.asset('assets/images/otherHuts.png', width: 220),
        ),
        Positioned(
          top: 650,
          left: 550,
          child: Image.asset('assets/images/otherHuts.png', width: 230),
        ),

        Positioned(
          top: 150,
          left: 1000,
          child: Image.asset('assets/images/well.png', width: 180),
        ),

        Positioned(
          top: 200,
          left: 1450,
          child: Image.asset('assets/images/pond.png', width: 300),
        ),

        // ── CENTER (Main Screen/Spawn) ──
        Positioned(
          top: 200,
          left: 1850,
          child: GestureDetector(
            onTap: () => StorageOverlay.openStorage(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/storage.png', width: 250),
          ),
        ),
        Positioned(
          top: 480,
          left: 1000,
          child: Image.asset('assets/images/hutlevel1.png', width: 300),
        ),

        // ── LEFT SIDE (Market Area) ──
        Positioned(
          top: 350,
          left: 300,
          child: GestureDetector(
            onTap: () => StockMarketOverlay.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/stock_market.png', width: 320),
          ),
        ),

        Positioned(
          top: 750,
          left: 100,
          child: GestureDetector(
            onTap: () => MarketWidgetState.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/market.png', width: 550),
          ),
        ),
        Positioned(
          top: 880,
          left: 80,
          child: GestureDetector(
            onTap: () => MarketWidgetState.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/market.png', width: 550),
          ),
        ),
        Positioned(
          top: 820,
          left: 10,
          child: GestureDetector(
            onTap: () => MarketWidgetState.openMarket(
              context,
              _player,
              () => setState(() {}),
            ),
            child: Image.asset('assets/images/market.png', width: 450),
          ),
        ),

        // ── RIGHT SIDE (Farming Area) ──
        Positioned(
          bottom: 50,
          right: 150,
          child: Container(
            width: 550,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF4E342E),
              border: Border.all(color: const Color(0xFF3E2723), width: 3),
            ),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 275 / 200,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final segment = _player.landSegments[index];
                return GestureDetector(
                  onTap: () => _handleFieldTap(segment),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF3E2723).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (segment.isPloughed || segment.ploughProgress > 0)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PloughedFieldPainter(),
                            ),
                          ),
                        if (segment.sownCrop != null)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  segment.sownCrop!.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                if (!segment.isReadyToHarvest)
                                  const Icon(
                                    Icons.timer,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        if (!segment.isOwned)
                          Positioned.fill(
                            child: Container(
                              color: Colors.grey.withOpacity(0.7),
                              child: const Center(
                                child: Text(
                                  '🔒',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Positioned(
          top: 600,
          left: 1000,
          child: Image.asset('assets/images/farmer.png', width: 60),
        ),

        Positioned(
          top: 450,
          left: 1750,
          child: SizedBox(
            width: 250,
            height: 200,
            child: Stack(
              children: [
                Positioned(top: 0, left: 0, right: 0, child: _buildFenceRow(3)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFenceRow(3),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: -20,
                  child: RotatedBox(quarterTurns: 1, child: _buildFenceRow(2)),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: -20,
                  child: RotatedBox(quarterTurns: 1, child: _buildFenceRow(2)),
                ),
              ],
            ),
          ),
        ),

        _buildParkingAreaItems(),

        Positioned.fill(
          child: IgnorePointer(
            child: VillageLife(
              worldWidth: AppSizes.worldWidth,
              worldHeight: AppSizes.worldHeight,
              obstacles: [
                Rect.fromLTWH(1500, 650, 550, 400),
                Rect.fromLTWH(1000, 480, 280, 200),
                Rect.fromLTWH(1850, 200, 250, 250),
                Rect.fromLTWH(1750, 450, 250, 200),
                Rect.fromLTWH(1000, 150, 150, 150),
                Rect.fromLTWH(930, 520, 90, 90),
                Rect.fromLTWH(1450, 200, 280, 220),
                Rect.fromLTWH(100, 750, 550, 150),
                Rect.fromLTWH(80, 880, 550, 150),
                Rect.fromLTWH(10, 820, 450, 150),
                Rect.fromLTWH(300, 350, 300, 250),
                Rect.fromLTWH(140, 80, 220, 160),
                Rect.fromLTWH(20, 250, 210, 150),
                Rect.fromLTWH(530, 130, 230, 170),
                Rect.fromLTWH(820, 60, 220, 150),
                Rect.fromLTWH(750, 380, 240, 180),
                Rect.fromLTWH(1080, 320, 240, 160),
                Rect.fromLTWH(540, 650, 240, 180),
                Rect.fromLTWH(1800, 200, 230, 170),
                Rect.fromLTWH(1750, 450, 250, 200),
                Rect.fromLTWH(1790, 490, 140, 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Fixed HUD ────────────────────────────────────────────────────────────
  Widget _buildHUD() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSizes.sidebarWidth),
              Expanded(
                child: HudBar(
                  label: 'Level Progress',
                  progress: _player.levelProgress,
                  barColor: const Color(0xFFFF9933),
                  icon: Icons.star,
                  iconColor: const Color(0xFFFF9933),
                  textColor: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HudBar(
                  label: 'Emergency Fund',
                  progress: null,
                  balanceText: '₹${_player.emergencyFund.toInt()}',
                  barColor: Colors.white,
                  icon: Icons.shield,
                  iconColor: const Color(0xFF000080),
                  textColor: const Color(0xFF000080),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HudBar(
                  label: 'Total Balance',
                  balanceText: '₹${_player.totalBalance}',
                  barColor: const Color(0xFF138808),
                  icon: Icons.currency_rupee,
                  iconColor: const Color(0xFF138808),
                  textColor: const Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      left: 8,
      top: AppSizes.hudHeight + 10,
      child: Column(
        children: [
          SidebarButton(
            imagePath: 'assets/images/farmer.png',
            label: 'Profile',
            color: const Color(0xFFFF9933),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ProfileOverlay(
                  player: _player,
                  onClose: () => Navigator.pop(context),
                ),
              );
            },
          ),
          SidebarButton(
            icon: Icons.chat_bubble,
            label: 'Chat',
            color: const Color(0xFF000080),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ChatOverlay(
                  player: _player,
                  adjustBalance: (delta) {
                    setState(() {
                      _player.totalBalance += delta;
                    });
                  },
                  onClose: () => Navigator.pop(context),
                ),
              );
            },
          ),
          SidebarButton(
            imagePath: 'assets/images/quiz.png',
            label: 'Quiz',
            color: const Color(0xFF138808),
            onTap: () {
              setState(() {
                _isQuizMode = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorldBadge() {
    if (_isQuizMode) {
      return Positioned(
        top: 100,
        right: 18,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isQuizMode = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'QUIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isParisthitiMode) {
      return Positioned(
        top: 100,
        right: 18,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isParisthitiMode = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'BACK ->',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
      top: 100,
      right: 18,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isParisthitiMode = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.fill,
              opacity: 0.9,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            constraints: const BoxConstraints(minWidth: 140, minHeight: 90),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                SizedBox(height: 8),
                Text(
                  'Paristhiti AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParkingAreaItems() {
    final vehicles = _player.marketItems
        .where((item) => item.category == 'vehicle' && (item.owned || _player.rentedItems.any((r) => r.item.name == item.name)))
        .toList();

    return Stack(
      children: [
        if (vehicles.any((v) => v.name == 'Bullock Cart'))
          Positioned(
            top: 480,
            left: 1760,
            child: Image.asset('assets/images/bullockCart.png', width: 140),
          ),
        if (vehicles.any((v) => v.name == 'Tractor'))
          Positioned(
            top: 530,
            left: 1840,
            child: const Text('🚜', style: TextStyle(fontSize: 80)),
          ),
      ],
    );
  }

  void _dialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFieldTap(LandSegment segment) {
    if (!segment.isOwned) {
      _confirmLandPurchase(segment);
    } else if (!segment.isPloughed) {
      _showPloughOptions(segment);
    } else if (segment.sownCrop == null) {
      _showSeedSelection(segment);
    } else if (segment.isReadyToHarvest) {
      _confirmHarvest(segment);
    } else {
      _dialog(
        'Crop Growing',
        'This ${segment.sownCrop!.name} is still growing. Please wait for it to mature!',
      );
    }
  }

  void _showPloughOptions(LandSegment segment) {
    final vehicles = _player.marketItems
        .where((item) => item.category == 'vehicle' && (item.owned || _player.rentedItems.any((r) => r.item.name == item.name)))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plough Field?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a vehicle to plough the field:'),
            const SizedBox(height: 16),
            if (vehicles.isEmpty)
              const Text(
                'You don\'t own or rent any vehicles! You can buy/rent one at the Market.',
                style: TextStyle(color: Colors.red),
              )
            else
              ...vehicles.map(
                (v) => ListTile(
                  leading: Text(v.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(v.name),
                  subtitle: Text(
                    v.name == 'Tractor'
                        ? 'Fast - Takes 10s'
                        : 'Slower - Takes 30s',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _startPloughing(segment, v);
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _startPloughing(LandSegment segment, MarketItem vehicle) {
    int seconds = 30;
    if (vehicle.name == 'Tractor') {
      switch (vehicle.quality) {
        case ItemQuality.high:
          seconds = 5;
          break;
        case ItemQuality.medium:
          seconds = 10;
          break;
        case ItemQuality.worst:
          seconds = 20;
          break;
      }
    }

    setState(() {
      segment.ploughProgress = 0.1;
    });

    _showPloughingProgress(segment, seconds);
  }

  void _showPloughingProgress(LandSegment segment, int seconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (segment.ploughProgress < 1.0) {
              setState(() {
                segment.ploughProgress += 0.1 / seconds;
                if (segment.ploughProgress >= 1.0) {
                  segment.ploughProgress = 1.0;
                  segment.isPloughed = true;
                  Navigator.pop(ctx);
                }
              });
              setDialogState(() {});
            }
          });

          return AlertDialog(
            title: const Text('Ploughing in progress...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: segment.ploughProgress),
                const SizedBox(height: 8),
                Text('${(segment.ploughProgress * 100).toInt()}% Complete'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmLandPurchase(LandSegment segment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Expand Your Farm?'),
        content: Text(
          'Do you want to buy this plot of land for ₹${segment.purchasePrice}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('MAYBE LATER'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_player.totalBalance >= segment.purchasePrice) {
                setState(() {
                  _player.totalBalance -= segment.purchasePrice;
                  segment.isOwned = true;
                });
                Navigator.pop(ctx);
              } else {
                _dialog(
                  'Insufficient Funds',
                  'You need more money to buy land!',
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'PURCHASE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSeedSelection(LandSegment segment) {
    final ownedSeeds = _player.marketItems
        .where((item) => item.category == 'seeds' && item.quantity > 0)
        .toList();

    if (ownedSeeds.isEmpty) {
      _dialog(
        'No Seeds',
        'You don\'t have any seeds! Visit the Market to buy some.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Seed to Sow'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ownedSeeds.length,
            itemBuilder: (context, index) {
              final seed = ownedSeeds[index];
              return ListTile(
                leading: Text(seed.emoji, style: const TextStyle(fontSize: 24)),
                title: Text('${seed.name} (${seed.qualityLabel})'),
                subtitle: Text(
                  'Qty: ${seed.quantity} | Growth: ${seed.growthDays} mins',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmSow(segment, seed);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmSow(LandSegment segment, MarketItem seed) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sow Seed?'),
        content: Text('Do you want to sow ${seed.name} on this plot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                seed.quantity -= 1;
                segment.sownCrop = seed;
                segment.sowTime = DateTime.now();
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('SOW', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmHarvest(LandSegment segment) {
    final crop = segment.sownCrop!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ready to Harvest!'),
        content: Text(
          'Do you want to harvest this ${crop.name}? It will be moved to storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NOT YET'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                try {
                  final storedItem = _player.storageInventory.firstWhere(
                    (item) => item.name == crop.name,
                  );
                  storedItem.quantity += 1;
                } catch (e) {
                  final newItem = StoredCrop(
                    name: crop.name,
                    emoji: crop.emoji,
                    quantity: 1,
                    sellPrice: crop.profit ?? 0,
                  );
                  _player.storageInventory.add(newItem);
                }
                segment.sownCrop = null;
                segment.sowTime = null;
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('HARVEST', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFenceRow(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Image.asset('assets/images/fence.png', width: 80),
      ),
    );
  }
}

class _PloughedFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3E2723).withOpacity(0.4)
      ..strokeWidth = 2;

    for (double i = 10; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
